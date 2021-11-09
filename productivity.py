import csv
from datetime import datetime

from pydriller import Repository


def get_commit_prod(repo_list):
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
                    wd_commit = prod_dict[wd_id][0]+1
                    prod_dict.update({wd_id: [wd_commit, team_size]})
                else:
                    team_size = len(author_lcd_dict.keys())
                    prod_dict.update({wd_id: [1, team_size]})

            except Exception as error:
                print('[Productivity] Unexpected Error ', error)

        write_prod(repo, prod_dict)
        summary.update({repo: [from_date, end_date, commit_num, len(author_dict.keys())]})
        write_authors(repo, author_dict)
    write_summary(summary)


def write_prod(repo, prod_dict):
    try:
        print('prod writer start')
        with open('prod1.csv', 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            for wd_id in prod_dict.keys():
                writer.writerow([repo, wd_id, prod_dict[wd_id][0], prod_dict[wd_id][1]])
        print('prod writer complete')
    except:
        print('Unexpected Error when writing summary for ', repo)


def write_summary(summary):
    try:
        print('summary writer start')
        with open('summary.csv', 'w', newline='') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(['Repository', 'From Date', 'End Date', 'NCommit', 'NContributor'])
            for repo in summary.keys():
                writer.writerow([repo, summary[repo][0], summary[repo][1], summary[repo][2], summary[repo][3]])
        print('summary writer complete')
    except:
        print('Unexpected Error when writing summary for ', repo)


def write_authors(repo, authors):
    try:
        file_name = repo.replace('.git', '').replace('/', '').replace('.', '').replace(':', '')+'.csv'
        print('author writer start: ', file_name)
        with open('./author_info/'+file_name, 'w', newline='', encoding='gbk') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(['Name', 'Email'])
            for author in authors.keys():
                writer.writerow([authors[author], author])
        print('author writer complete')
    except Exception as error:
        print('Unexpected Error when writing author: ', error)


def get_author_intervals(repo_list):
    # last_date = datetime.now()
    # is_first = True
    # num_commit = 0
    for repo in repo_list:
        print("Mining repo: ", repo, "...")
        author_interval_dict = {}
        for commit in Repository(repo).traverse_commits():
            try:
                date = commit.committer_date
                # if is_first:
                #     last_date = date
                #     is_first = False
                # print(date - last_date)
                # last_date = date
                author_email = commit.author.email
                if author_email in author_interval_dict.keys():
                    last_date = author_interval_dict[author_email][0]
                    curr_interval = (date-last_date).total_seconds()
                    max_interval = author_interval_dict[author_email][1]
                    if curr_interval > max_interval:
                        author_interval_dict[author_email][1] = curr_interval
                    author_interval_dict[author_email][0] = date
                else:
                    author_interval_dict.update({author_email: [date, 0.00]})
                # print(commit.hash)
                # print(commit.msg)
                # print(commit.author.name)

                # for file in commit.modified_files:
                #     print(file.filename, ' has changed')
            except:
                print('unhandled exception')

        write_author_intervals(author_interval_dict)

        # for author_date in author_interval_dict.keys():
        #     print(author_date, author_interval_dict[author_date])
        #
        # for interval in author_interval_list:
        #     print(interval)


def read_repo_list(file_dir):
    repo_list = []
    with open(file_dir, newline='') as csv_file:
        list_reader = csv.reader(csv_file)
        index = 0
        for row in list_reader:
            if index != 0:
                repo_list.append(row[1])
            index += 1
            # repo_list.append(row[1])
    return repo_list


def write_author_intervals(intervals):
    try:
        print('write start')
        with open('author_intervals1.csv', 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            for email in intervals.keys():
                interval = intervals[email][1]
                if interval > 0.00:
                    writer.writerow([str(email), interval])
        print('Repo complete')
    except:
        print(email)


def write_commit_prod(prod_dict):
    try:
        print('write start')
        with open('author_intervals1.csv', 'a', newline='') as csv_file:
            writer = csv.writer(csv_file)
            for email in prod_dict.keys():
                interval = prod_dict[email][1]
                if interval > 0.00:
                    writer.writerow([str(email), interval])
        print('Repo complete')
    except:
        print(email)


if __name__ == '__main__':
    print('Reading csv...')
    repo_list = read_repo_list('repoinfo_waupdate_retry.csv')
    print('Start to get interval list...')
    # with open('author_intervals1.csv', 'w', newline='') as csv_file:
    #     writer = csv.writer(csv_file)
    #     writer.writerow(['Email', 'Interval'])
    with open('prod1.csv', 'w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(['Repository', 'WindowID', 'NCommits', 'TeamSize'])
    get_commit_prod(repo_list)
    # get_author_intervals(repo_list)
    # get_repo_summary()
