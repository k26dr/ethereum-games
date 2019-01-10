# Building Games with Ethereum Smart Contracts

This is the official code repository for the Apress
publication [Building Games with Ethereum Smart Contracts](https://www.apress.com/us/book/9781484234914).

## Getting Started

You will need the Truffle framework to properly run the code inside this repo. 

```
npm install -g truffle@4.0.7
```

The version number is required because the new Truffle 5 uses a different Solidity compiler
and build system that breaks the repo as it's currently structured. 

## Overview

Solidity contracts are located in the contracts/ folder. 

Tests for the more complex contracts are located in the test/ folder.

The migrations/ folder is Truffle-specific and its usage is explained in the book.
