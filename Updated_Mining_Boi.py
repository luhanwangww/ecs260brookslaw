import csv
from datetime import datetime
from pydriller import Repository


# Copied & modified
def get_commit_prod(repo_list, language):
    # {repo: [from_date, end_date, commit_num, contributor_num]}
    summary = {}
    for repo in repo_list:
        print('[Productivity] Mining repo: ', repo, '...')
        # for summary
        author_dict = {}
        commit_num = 0
        from_date = datetime(1970, 1, 1)
        end_date = datetime.now()

        # author last commit date dict {auth_email: last_commit_date}
        author_lcd_dict = {}
        # productivity dict {repo_name: [wd_id, prod_in_prod_wd, team_size]}
        prod_dict = {}

        wd_id = 0
        prod_wd = 7
        team_wd = 444

        is_first_commit = True
        for commit in Repository(repo).traverse_commits():
            try:
                author_email = commit.author.email
                author_name = commit.author.name
                date = commit.committer_date

                author_dict.update({author_email: author_name})
                commit_num += 1
                end_date = date

                if is_first_commit:
                    from_date = date
                    is_first_commit = False

                author_lcd_dict.update({author_email: date})
                pop_list = []
                for email in author_lcd_dict.keys():
                    if (date - author_lcd_dict[email]).total_seconds() > team_wd*60*60*24:
                        pop_list.append(email)
                for pop in pop_list:
                    author_lcd_dict.pop(pop)

                wd_id = int((date - from_date).total_seconds())//(prod_wd*60*60*24)
                if wd_id in prod_dict.keys():
                    team_size = len(author_lcd_dict.keys())
                    wd_commit = prod_dict[wd_id][1]+1
                    wd_churn = prod_dict[wd_id][2]+commit.lines
                    prod_dict.update({wd_id: [language[repo], wd_commit, wd_churn, team_size]})
                else:
                    team_size = len(author_lcd_dict.keys())
                    prod_dict.update({wd_id: [language[repo], 1, commit.lines, team_size]})

            except Exception as error:
                print('[Productivity] Unexpected Error ', error)

        write_prod(repo, prod_dict)
        summary.update({repo: [from_date, end_date, commit_num, len(author_dict.keys()), language[repo]]})
        # write_authors(repo, author_dict)
    write_summary(summary)


# Copied & modified
def write_prod(repo, prod_dict):
    try:
        print('prod writer start')
        with open('zz_prod2.csv', 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            for wd_id in prod_dict.keys():
                writer.writerow([repo, prod_dict[wd_id][0], wd_id, prod_dict[wd_id][1],
                                 prod_dict[wd_id][2], prod_dict[wd_id][3]])
        print('prod writer complete')
    except Exception as e_msg:
        print('Unexpected Error when writing prod for ', repo, e_msg)


# Plagiarized. Nah, copied XD.
def write_summary(summary):
    try:
        print('summary writer start')
        with open('zz_summary2.csv', 'w', newline='') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(['Repository', 'From Date', 'End Date', 'NCommit', 'NContributor', "Language"])
            for repo in summary.keys():
                writer.writerow([repo, summary[repo][0], summary[repo][1], summary[repo][2],
                                 summary[repo][3], summary[repo][4]])
        print('summary writer complete')
    except Exception as e_msg:
        print('Unexpected Error when writing summary for ', repo, e_msg)


# Read CSV
def info_reader(_file):
    repo_list = []
    language = {}
    with open(_file, "r") as f:
        scanner = csv.reader(f)
        line0 = True
        for row in scanner:
            if line0:
                line0 = False
                continue
            repo_list.append(row[1])
            language[row[1]] = row[2]

            # For EZ test
            if len(repo_list) >= 4:
                break

    return repo_list, language


def main():
    repo_list, language = info_reader("apache.csv")
    with open("zz_prod2.csv", "w") as prod_csv:
        prod_csv_writer = csv.writer(prod_csv)
        prod_csv_writer.writerow(['Repository', "Language", 'WindowID', 'NCommits', 'Code_Churn', 'TeamSize'])
    get_commit_prod(repo_list, language)


if __name__ == "__main__":
    main()
