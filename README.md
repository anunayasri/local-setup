# Setup a New Mac

TODO: How to copy settings of GUI apps(like spectacle) ❓

## Setup script

```sh
GIT_USERNAME=Xxx GIT_EMAIL=xxx@gmail.com setup-init.sh
```

## Install npm using nvm

https://nodejs.org/en/download/package-manager

```sh
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# download and install Node.js (you may need to restart the terminal)
nvm install 22

# verifies the right Node.js version is in the environment
node -v # should print `v22.11.0`

# verifies the right npm version is in the environment
npm -v # should print `10.9.0`
```

## Install Python

!!! note
    We don't want to change the MacOS's default python installtion.

We will download python from [python.org](https://www.python.org/downloads/).
