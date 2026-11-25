# How to Use `gen3_helm_images.py` (and image_ages.py)

This guide walks you through running the script that checks which image tags each gen3-helm chart uses (and optionally, how old the images are).

## Step 1: Set up

You need **Python 3.10+** and a local clone of gen3-helm, since the script lives in its `tools/image-tags/` folder. Run the script in a virtual environment. Run:

```
git clone https://github.com/uc-cdis/gen3-helm.git   # skip if you already have it
cd gen3-helm/tools/image-tags
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
python -m pip install -r requirements.txt
```

The virtual environment is optional but recommended; reactivate it in each new terminal. Use `python3` or `py` if `python` points to an older version. An internet connection is needed unless you use `--local` (see below).

## Step 2: Run the script

```
python gen3_helm_images.py
```

The script downloads the latest charts from GitHub and prints the results. It takes a few seconds.

### Optional settings

You can add these options to the end of the command:

| Option | What it does |
|---|---|
| `--allow-empty` | Never flags blank tags (`""`). By default, a blank tag is judged by the version it falls back to (see Step 3) |
| `--include-missing` | Also flags charts that have no image tag at all |
| `--ref BRANCH` | Checks a different branch instead of `master` |
| `--local PATH` | Uses a gen3-helm folder already on your computer instead of downloading it |
| `--json` | Prints the results as JSON (useful for other tools) |
| `--check` | Fails if any tag may be misread by Helm (see Step 3) |
| `--check unquoted` | Stricter: fails if any tag is unquoted |
| `--help` | Shows all options |

For example:

```
python gen3_helm_images.py --allow-empty
```

### Checking your own changes

To check the gen3-helm folder locally, point `--local` at the repository root, two folders up:

```
python gen3_helm_images.py --local ../..
```

This is a quick way to catch a problem tag before you open a pull request.

## Step 3: Read the results

The output has a table of every chart, followed by a list of the charts to review.

**1. A table of every chart:**

```
CHART      REPOSITORY                 TAG               QUOTED
fence      quay.io/cdis/fence         master            yes
funnel     quay.io/cdis/funnel        main-gen3         no
arborist   quay.io/cdis/arborist      (empty → master)  yes
dashboard  quay.io/cdis/gen3-statics  2025.10           no *
alloy      -                          -                 -
```

- **TAG** shows the tag exactly as written in the chart's file. If the tag is blank, Helm uses the chart's default version (`appVersion` in its `Chart.yaml`), shown as `(empty → master)`. That default is what's checked against `main`/`master`. `(empty, no appVersion)` means there's nothing to fall back on, which is always flagged.
- **QUOTED** shows whether the tag has quote marks around it in the file.
  - `yes` / `no`: quoted or not quoted
  - `no *`: not quoted **and** it may be read as a number, date or true/false. For example, `2025.10` would be deployed as `2025.1`. A note under the table appears when this happens. Adding quotes around the value in `values.yaml` always fixes it.
- `-` means the chart has no image setting.

Below the table, the script also says how many charts have an unquoted tag.

**2. A list of charts whose tag is not `main` or `master`.** These are the ones to review. (Note: Some use an image tag of "latest". This is still flagged, because some images with the "latest" tag are not actually the most recent, and can be quite old.)

### Using `--check` (for automated checks)

The script always ends with an **exit code** that automated tools, such as GitHub Actions, can act on. Code `1` only happens with `--check`:

| Exit code | Meaning |
|---|---|
| `0` | All good |
| `1` | The check found problem tags (they're listed in an `ERROR` line) |
| `2` | Something went wrong, such as no internet or the wrong folder |

To see the exit code after running the script, type `echo $?` (Mac/Linux) or `echo %errorlevel%` (Windows Command Prompt).

## Step 4 (optional): Check that everything works

```
python -m pip install -r requirements-dev.txt
python -m pytest -q
```

This tests every tool in the folder. If you see something like `165 passed`, everything is working correctly. The tests don't use the internet.

## Also in this folder: image ages

`image_ages.py` prints the same chart list as a table, plus when each image tag was last pushed and how long ago. It needs internet access to quay.io and Docker Hub:

```
python image_ages.py > image_ages.md
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `python` is not recognized / command not found | Try `python3` or `py` instead. |
| `No module named 'yaml'` or `'requests'` | Activate your virtual environment, or rerun the install in Step 1. |
| `TypeError` mentioning `slots` | Your Python is older than 3.10. Install a newer version. |
| `ERROR: Could not load charts` | Check your internet connection or the branch name. With `--local`, make sure the folder contains a `helm` subfolder. |
| `No such file or directory` | Run the commands from `gen3-helm/tools/image-tags`. |
