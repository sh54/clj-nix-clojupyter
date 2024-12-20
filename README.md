# Aim

Build a Clojure project into a Jupyter kernel using [Clojupyter](https://github.com/clojupyter/clojupyter/blob/master/doc/library.md).

# Issue

Including dependency `clojupyter/clojupyter {:mvn/version "0.4.332"}` breaks the
build. Clojure stops when trying to build a class path and before `build.clj` is
even touched.

The following build in the devshell works and produces the target jar:

```
clj -X:build:prod uberjar :build/jar-name "target/clojupyter-standalone.jar"
```

But building it in nix fails:

```
nix build
```

Logs:

```
Running phase: unpackPhase
@nix { "action": "setPhase", "phase": "unpackPhase" }
unpacking source archive /nix/store/8j4d6xz4has33zmzk1bz6r65dsz266xc-frbs1kcj05pjvz0qy1yl68j3v0kr8bdj-source
source root is frbs1kcj05pjvz0qy1yl68j3v0kr8bdj-source
Running phase: patchPhase
@nix { "action": "setPhase", "phase": "patchPhase" }
Running phase: updateAutotoolsGnuConfigScriptsPhase
@nix { "action": "setPhase", "phase": "updateAutotoolsGnuConfigScriptsPhase" }
Running phase: configurePhase
@nix { "action": "setPhase", "phase": "configurePhase" }
no configure script, doing nothing
Running phase: preBuildPhase
@nix { "action": "setPhase", "phase": "preBuildPhase" }
Running phase: buildPhase
@nix { "action": "setPhase", "phase": "buildPhase" }
Picked up JAVA_TOOL_OPTIONS: -Duser.home=/nix/store/z6han4rrw7dnb8v35pmchfzzdw2dl5rg-clj-cache
Error building classpath. Unable to resolve org.clojure/clojure version: [1.3.0,)
```

In the clojure-wrapper thingy it looks like it fails [here](https://github.com/clojure/clojure-api-doc/blob/31aed351a9ca2607958e69c4886dc29cbbccdd40/cli/bin/clojure#L438)
running `clojure.tools.deps.alpha.script.make-classpath2`.

# Getting something to build

Remove `clojupyter/clojupyter   {:mvn/version "0.4.332"}` dependency from deps.edn.

Run `nix run github:jlesquembre/clj-nix#deps-lock`.

Run `nix build`.
