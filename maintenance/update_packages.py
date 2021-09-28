#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python3Packages.toml python3Packages.GitPython

import subprocess
import tempfile
import toml
from git import Repo
from argparse import ArgumentParser

update_all_hashes = False

parser = ArgumentParser()
parser.add_argument("-d", "--date", dest="date", default=None, help="use last commit before DATE", metavar="DATE")
parser.add_argument("-y", "--yes", dest="yes", action="store_true", help="\"yes\" to all prompts")
parser.add_argument("pkg_meta_file",
                    help="Path to the TOML file containing the package metadata",
                    default="./pkgs/litex_packages.toml")
args = parser.parse_args()

package_meta_file = args.pkg_meta_file

def prompt(message):
    if args.yes:
      return True

    reply = str(input("{} [y/n] ".format(message))).lower().strip()
    if reply[0] == 'y':
        return True
    if reply[0] == 'n':
        return False
    else:
        return prompt(message)

try:
    meta_file = open(package_meta_file, "r")
    meta = toml.load(meta_file)
    meta_file.close()
except FileNotFoundError:
    print("Package meta file \"{}\" not found. Are you in the repository root?"
          .format(package_meta_file))

print("Parsed package metadata from \"{}\"".format(package_meta_file))

for pname, package in meta.items():
    print("Processing package \"{}\"".format(pname))

    with tempfile.TemporaryDirectory(prefix=pname) as tmpdir:
        if set(["github_user", "github_repo", "git_revision"]) \
           <= set(package.keys()):
            github_user = package["github_user"]
            github_repo = package["github_repo"]
            git_revision = package["git_revision"]

            print("Checking for a new revision on the master branch of {}/{}".format(github_user, github_repo))
            r = Repo.clone_from("https://github.com/{}/{}.git".format(github_user, github_repo), tmpdir, filter="tree:0", bare=True)

            head = next(r.iter_commits("master", None, before=args.date)) if args.date != None else r.commit("master")
            pinned = r.commit(git_revision)

            commit_count_diff = head.count() - pinned.count()

            update_hash = False

            if commit_count_diff != 0:
                print("Current head has {} more commits:".format(commit_count_diff))
                print("  {}\n  \"{}\"\n  -- {}".format(head, head.summary, head.authored_datetime))
                print("  vs")
                print("  {}\n  \"{}\"\n  -- {}".format(pinned, pinned.summary, pinned.authored_datetime))
                if prompt("  -> Do you want to update?"):
                    meta[pname]["git_revision"] = str(head)
                    update_hash = True

            if update_all_hashes and not update_hash:
                print("No new revision available, but told to update the hash anyways.")
                update_hash = True

            if update_hash:
                    print("Okay, obtaining Nix hash for {}...".format(pname))
                    url = "https://github.com/{}/{}/archive/{}.tar.gz".format(
                        github_user,
                        github_repo,
                        head,
                    )
                    prefetchHash = subprocess.check_output([
                        "nix-prefetch-url",
                        "--type",
                        "sha256",
                        "--unpack",
                        url,
                    ]).decode("utf-8").strip()
                    print("...got hash {}".format(prefetchHash))
                    meta[pname]["github_archive_nix_hash"] = prefetchHash

with open(package_meta_file, "w") as newfile:
    toml.dump(meta, newfile)
