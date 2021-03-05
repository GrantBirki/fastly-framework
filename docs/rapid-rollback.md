# Rapid Rollback 🔄

The Rapid Rollback pipeline stage is a manually triggered action that reverts a deploy to the previous active version of a Fastly Service.

This is a *break glass* feature and should only be used in emergencies (outages, production issues, failures, etc).

## Key Features of Rapid Rollback

* Rapid Rollbacks will revert a change in under **60 seconds**.
* Rapid Rollbacks cannot be undone from the same pipeline once triggered.
* When a Rapid Rollback is triggered it will break the symmetry between the Pipeline/GitLab-Repo and the state of the service in Fastly. More on this below.
* Rapid Rollbacks active the previous active version.

## Rapid Rollback Runbook

You triggered a Rapid Rollback? Here is what to do next.

Since the Rapid Rollback brought the Fastly Service back to the previous version we need to do the same to our GitLab Repo so they are symmetrical.

**NOTE**: If this rollback is apart of a production issue, ensure proper channels are notified and procedures are followed before continuing.

1. Revert Git changes. `abcd1234` is an example short commit sha.

    ```text
    git revert --no-commit abcd1234..HEAD
    git commit
    ```

    What does this do?

    > This will revert everything from the HEAD back to the commit hash, meaning it will recreate that commit state in the working tree as if every commit after `abcd1234` had been walked back. You can then commit the current tree, and it will create a brand new commit essentially equivalent to the commit you "reverted" to. The `--no-commit` flag lets git revert all the commits at once- otherwise you'll be prompted for a message for each commit in the range, littering your history with unnecessary new commits.

2. Redeploy
    1. Redeploy the commit as it is to make the GitLab Repo and the Fastly Service symmetrical again. This is the **suggested** method unless a fix is immediately known. Simply create a new branch, commit, and push changes.
    2. Apply changes/fixes and redeploy. This will create a new GitLab commit and push that change to Fastly. This will make both symmetrical again and also create new versions in both which will match.
