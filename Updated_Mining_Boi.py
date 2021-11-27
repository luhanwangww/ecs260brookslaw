import csv
from datetime import datetime
from pydriller import Repository


class SimpleCommit:
    def __init__(self, commit_hash, author_email, author_name, lines, date, is_release):
        self.commit_hash = commit_hash
        self.author_email = author_email
        self.author_name = author_name
        self.lines = lines
        self.date = date
        self.is_release = is_release

    def __lt__(self, com):
        return self.date < com.date

    def __le__(self, com):
        return self.date <= com.date


# Copied & modified
def get_release_interval(repo_list, language):
    # {repo: [from_date, end_date, commit_num, code_churn, contributor_num, Language]}
    bad_repo = []
    print("Going thru " + str(len(repo_list)) + " repos...")
    count = 1
    for repo in repo_list:
        print('('+str(count)+'/'+str(len(repo_list))+') ', '[Productivity] Mining repo: ', repo, '...')
        # for summary
        author_dict = {}
        commit_num = 0
        from_date = datetime(1970, 1, 1)
        end_date = datetime.now()

        # author last commit date dict {auth_email: last_commit_date}
        author_lcd_dict = {}
        # productivity dict {repo_name: [wd_id, prod_in_prod_wd, team_size]}
        prod_dict = {}
        release_dict = {}

        prod_wd = 7
        team_wd = 525

        is_first_commit = True
        negative_id_detected = False
        r = []
        release_hash_list = []
        try:
            print("Collecting Release...")
            for commit in Repository(repo, only_releases=True).traverse_commits():
                release_hash_list.append(commit.hash)

            print("Collecting...")
            for commit in Repository(repo).traverse_commits():
                is_release = commit.hash in release_hash_list
                r.append(SimpleCommit(commit.hash, commit.author.email, commit.author.name, commit.lines, commit.committer_date, is_release))
                if len(r) % 1000 == 0:
                    print(len(r), "...")
            print("Sorting...")
            r.sort()
        except Exception as error:
            print("[Pydriller] " + repo + " skipped due to unexpected error.", error)
            bad_repo.append(repo)
            continue

        try:
            print("Analyzing...")
            ###
            last_release_date = r[0].date
            for commit in r:
                try:
                    author_email = commit.author_email
                    author_name = commit.author_name
                    date = commit.date
                    lines = commit.lines
                    ####
                    is_release = commit.is_release

                    commit_num += 1
                    end_date = date

                    if is_first_commit:
                        from_date = date
                        is_first_commit = False

                    email_segments = author_email.split('@')
                    name2 = author_email
                    if len(email_segments) > 0:
                        name2 = email_segments[0].replace('.', '').lower()
                    name1 = author_name.replace(' ', '').lower()
                    name = name1
                    if name2 in author_lcd_dict.keys():
                        name = name2
                    author_lcd_dict.update({name: date})
                    author_dict.update({name: author_email})

                    pop_list = []
                    for name in author_lcd_dict.keys():
                        if (date - author_lcd_dict[name]).total_seconds() > team_wd*60*60*24:
                            pop_list.append(name)
                    for pop in pop_list:
                        author_lcd_dict.pop(pop)

                    wd_id = int((date - from_date).total_seconds())//(prod_wd*60*60*24)
                    if wd_id in prod_dict.keys():
                        team_size = len(author_lcd_dict.keys())
                        wd_commit = prod_dict[wd_id][1]+1
                        wd_churn = prod_dict[wd_id][2]+lines
                        prod_dict.update({wd_id: [language[repo], wd_commit, wd_churn, team_size]})
                    else:
                        team_size = len(author_lcd_dict.keys())
                        prod_dict.update({wd_id: [language[repo], 1, lines, team_size]})

                    # Record release intervals
                    if is_release:
                        release_interval = (date - last_release_date).total_seconds()
                        last_release_date = date
                        release_dict.update({commit.commit_hash: [language[repo], wd_id, release_interval, team_size]})

                except Exception as error:
                    print('[Productivity] Unexpected Error ', error)
        except Exception as error:
            print("Repository " + repo + " has been skipped due to unexpected error: ", error)
            bad_repo.append(repo)
            continue
        if negative_id_detected:
            print("Repository " + repo + "skipped due to negative window id.")
            bad_repo.append(repo)
            continue
        write_prod(repo, prod_dict)
        write_releases(repo, release_dict)
        # write_authors(repo, author_dict)
        count += 1
        summary = [from_date, end_date, commit_num, len(author_dict.keys()), language[repo], len(release_hash_list)]
        write_summary(repo, summary)
    return bad_repo


# Copied & modified
def write_prod(repo, prod_dict):
    try:
        print('prod writer start')
        with open(prod_csv_path, 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            for wd_id in prod_dict.keys():
                writer.writerow([repo, prod_dict[wd_id][0], wd_id, prod_dict[wd_id][1],
                                 prod_dict[wd_id][2], prod_dict[wd_id][3]])
        print('prod writer complete')
    except Exception as e_msg:
        print('Unexpected Error when writing prod for ', repo, e_msg)


def write_releases(repo, release_dict):
    try:
        print('release writer start')
        with open(release_csv_path, 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            for commit_hash in release_dict.keys():
                # language, wd_id, release_interval, team_size
                writer.writerow([repo, commit_hash, release_dict[commit_hash][0], release_dict[commit_hash][1],
                                 release_dict[commit_hash][2], release_dict[commit_hash][3]])
        print('prod writer complete')
    except Exception as e_msg:
        print('Unexpected Error when writing prod for ', repo, e_msg)


# Plagiarized. Nah, copied XD.
def write_summary(repo, summary):
    try:
        print('summary writer start')
        with open(summary_csv_path, 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow([repo, summary[0], summary[1], summary[2], summary[3], summary[4], summary[5]])
        print('summary writer complete')
    except Exception as e_msg:
        print('Unexpected Error when writing summary for ', repo, e_msg)


# Read CSV
def info_reader(_file):
    print("Reading " + _file + "...")
    repo_list = []
    language = {}
    with open(_file, "r") as f:
        scanner = csv.reader(f)
        line0 = True
        for row in scanner:
            if line0:
                line0 = False
                continue
            path = ""
            if row[4] == "True":
                path = "../repo_buffer/" + row[0]
            else:
                path = row[1]
            repo_list.append(path)
            language[path] = row[2]

            # For EZ test
            """
            if len(repo_list) >= 10:
                break
            """

    return repo_list, language


repo_csv_path = "test.csv"
prod_csv_path = 'test_prod.csv'
release_csv_path = 'test_release.csv'
summary_csv_path = 'test_summary.csv'
bad_repo_csv_path = "test_bad_repo.csv"


def main():
    repo_list, language = info_reader(repo_csv_path)
    with open(prod_csv_path, "w", newline='') as prod_csv:
        prod_csv_writer = csv.writer(prod_csv)
        prod_csv_writer.writerow(['Repository', "Language", 'WindowID', 'NCommits', 'Code_Churn', 'TeamSize'])
    with open(release_csv_path, "w", newline='') as release_csv:
        prod_csv_writer = csv.writer(release_csv)
        prod_csv_writer.writerow(['Repository', 'Hash', 'Language', 'WindowID', 'ReleaseInterval', 'TeamSize'])
    with open(summary_csv_path, 'w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(['Repository', 'From Date', 'End Date', 'NCommit', 'NContributor', "Language", 'NRelease'])

    bad_repo = get_release_interval(repo_list, language)
    if len(bad_repo) > 0:
        print(str(len(bad_repo)) + " skipped repo appeared.")
        with open(bad_repo_csv_path, "w", newline='') as f:
            cw = csv.writer(f)
            cw.writerow(["Bad repo path"])
            for path in bad_repo:
                cw.writerow([path])


if __name__ == "__main__":
    main()
