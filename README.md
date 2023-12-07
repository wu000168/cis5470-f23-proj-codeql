# Python CodeQL Analysis

Authors: Zain Aamer, Jeff Tao, Zed Wu

# Instructions

To generate CodeQL databases (you must have the `codeql` CLI installed):

```
make db
```

To run queries, you must have the VSCode CodeQL extension installed.
If the databases do not appear in the sidebar, build the databases with the command above and restart VS Code.

![](docs/extension.png)

Be sure to select the corresponding database when executing a query (e.g. run `taint.ql` on the `taint` database).
