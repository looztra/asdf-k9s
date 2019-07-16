workflow "Delete Merged Branch" {
  resolves = ["Delete merged branch"]
  on = "pull_request"
}

action "Delete merged branch" {
  uses = "SvanBoxel/delete-merged-branch@v1.3.3"
  secrets = ["GITHUB_TOKEN"]
}
