import csv
from git import Repo


def cloner(url_list):
    for url in url_list:
        print("Cloning ", url[0])
        Repo.clone_from(url=url[1], to_path="../repo_buffer/"+url[0])


def read_csv(_file):
    over_size_list = []
    cr = csv.reader(_file)
    first_row = True
    for row in cr:
        if first_row:
            first_row = False
            continue
        if row[4] == "True":
            over_size_list.append([row[0], row[1]])
    return over_size_list


def main():
    with open("apache.csv", "r") as f:
        over_size_list = read_csv(f)
    print("Downloading "+str(len(over_size_list))+" repos...")
    cloner(over_size_list)


if __name__ == "__main__":
    main()
