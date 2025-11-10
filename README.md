# mzke-includes

## To add/install in a project

- Add as a submodule in the `mk` subdir:

```sh
git submodule add git@somewhere:somewhere-else/mzke-includes.git mk
```

- Copy the included `Mzkefile.example` from the subdir to the project root

```sh
cp mk/Mzkefile.example Mzkefile
```

- Overrides go in `<project>.inc.mk` in the root of the repo.

## To clone/pull as part of a project

```sh
git [clone|pull] --recurse-submodules
```
