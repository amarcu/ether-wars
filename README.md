# Ethereum Smart Contract Template

This development quick start template is heavily inspired by [Georgios's template](https://github.com/gakonst/dapptools-template). Over time it was migrated to use [foundry](https://github.com/gakonst/foundry) since dapptools was deprecated.

It requires [Foundry](https://github.com/gakonst/foundry) installed to run. You can find instructions here [Foundry installation](https://github.com/gakonst/foundry#installation).

On Windows follow the install documentation: https://book.getfoundry.sh/getting-started/installation



cargo install --git https://github.com/foundry-rs/foundry foundry-cli anvil --bins --locked
To update from source, run the same command again.

## Installation

To install dependencies run:
``make setup``

To compile the contracts run:
``make build``

To run a game:
``make play``
