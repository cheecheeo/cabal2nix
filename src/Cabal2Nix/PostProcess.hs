{-# LANGUAGE RecordWildCards #-}

module Cabal2Nix.PostProcess ( postProcess ) where

import Data.List
import Distribution.NixOS.Derivation.Cabal
import Distribution.Text ( display )

postProcess :: Derivation -> Derivation
postProcess deriv@(MkDerivation {..})
  | pname == "aeson" && version > Version [0,7] []
                                = deriv { buildDepends = "blaze-builder":buildDepends }
  | pname == "Agda"             = deriv { buildTools = "emacs":buildTools, phaseOverrides = agdaPostInstall }
  | pname == "alex" && version < Version [3,1] []
                                = deriv { buildTools = "perl":buildTools }
  | pname == "alex" && version >= Version [3,1] []
                                = deriv { buildTools = "perl":"happy":buildTools }
  | pname == "bindings-GLFW"    = deriv { extraLibs = "libXext":"libXfixes":extraLibs }
  | pname == "bits-extras"      = deriv { configureFlags = "--ghc-option=-lgcc_s":configureFlags, extraLibs = filter (/= "gcc_s") extraLibs }
  | pname == "Cabal"            = deriv { phaseOverrides = "preCheck = \"unset GHC_PACKAGE_PATH; export HOME=$NIX_BUILD_TOP\";" }
  | pname == "cabal-bounds"     = deriv { buildTools = "cabalInstall":buildTools }
  | pname == "cabal-install" && version >= Version [0,14] []
                                = deriv { phaseOverrides = cabalInstallPostInstall }
  | pname == "cairo"            = deriv { extraLibs = "pkgconfig":"libc":"cairo":"zlib":extraLibs }
  | pname == "cuda"             = deriv { phaseOverrides = cudaConfigurePhase, extraLibs = "cudatoolkit":"nvidia_x11":"stdenv.cc":extraLibs }
  | pname == "darcs"            = deriv { phaseOverrides = darcsInstallPostInstall }
  | pname == "dns"              = deriv { testTarget = "spec" }
  | pname == "editline"         = deriv { extraLibs = "libedit":extraLibs }
  | pname == "epic"             = deriv { extraLibs = "gmp":"boehmgc":extraLibs, buildTools = "happy":buildTools }
  | pname == "ghc-heap-view"    = deriv { phaseOverrides = ghciPostInstall }
  | pname == "ghc-mod"          = deriv { phaseOverrides = ghcModPostInstall pname version, buildTools = "emacs":"makeWrapper":buildTools }
  | pname == "ghc-parser"       = deriv { buildTools = "cpphs":"happy":buildTools, phaseOverrides = ghcParserPatchPhase }
  | pname == "ghc-paths"        = deriv { phaseOverrides = ghcPathsPatches }
  | pname == "ghc-vis"          = deriv { phaseOverrides = ghciPostInstall }
  | pname == "git-annex"        = deriv { phaseOverrides = gitAnnexOverrides, buildTools = "git":"rsync":"gnupg1":"curl":"wget":"lsof":"openssh":"which":"bup":"perl":buildTools }
  | pname == "github-backup"    = deriv { buildTools = "git":buildTools }
  | pname == "glade"            = deriv { extraLibs = "pkgconfig":"libc":extraLibs, pkgConfDeps = "gtkC":delete "gtk" pkgConfDeps }
  | pname == "glib"             = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "gloss-raster"     = deriv { extraLibs = "llvm":extraLibs }
  | pname == "GLUT"             = deriv { extraLibs = "glut":"libSM":"libICE":"libXmu":"libXi":"mesa":extraLibs }
  | pname == "graphviz"         = deriv { testDepends = "systemGraphviz":testDepends }
  | pname == "gtk"              = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "gtkglext"         = deriv { pkgConfDeps = "pangox_compat":pkgConfDeps }
  | pname == "gtk2hs-buildtools"= deriv { buildDepends = "hashtables":buildDepends }
  | pname == "gtksourceview2"   = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "haddock" && version < Version [2,14] []
                                = deriv { buildTools = "alex":"happy":buildTools }
  | pname == "haddock"          = deriv { phaseOverrides = haddockPreCheck }
  | pname == "hakyll"           = deriv { testDepends = "utillinux":testDepends }
  | pname == "happy"            = deriv { buildTools = "perl":buildTools }
  | pname == "haskeline"        = deriv { buildDepends = "utf8String":buildDepends }
  | pname == "haskell-src"      = deriv { buildTools = "happy":buildTools }
  | pname == "haskell-src-meta" = deriv { buildDepends = "uniplate":buildDepends }
  | pname == "HFuse"            = deriv { phaseOverrides = hfusePreConfigure }
  | pname == "highlighting-kate"= highlightingKatePostProcessing deriv
  | pname == "hlibgit2"         = deriv { testDepends = "git":testDepends }
  | pname == "HList"            = deriv { buildTools = "diffutils":buildTools }
  | pname == "hmatrix"          = deriv { extraLibs = "liblapack":"blas": filter (/= "lapack") extraLibs }
  | pname == "hmatrix-special"  = deriv { extraLibs = "gsl":extraLibs }
  | pname == "hoogle"           = deriv { testTarget = "--test-option=--no-net" }
  | pname == "hspec"            = deriv { doCheck = False }
  | pname == "GlomeVec"         = deriv { buildTools = "llvm":buildTools }
  | pname == "idris"            = deriv { buildTools = "happy":buildTools, extraLibs = "gmp":"boehmgc":extraLibs }
  | pname == "language-c-quote" = deriv { buildTools = "alex":"happy":buildTools }
  | pname == "language-java"    = deriv { buildDepends = "syb":buildDepends }
  | pname == "leksah-server"    = deriv { buildDepends = "process-leksah":buildDepends }
  | pname == "lhs2tex"          = deriv { extraLibs = "texLive":extraLibs, phaseOverrides = lhs2texPostInstall }
  | pname == "libffi"           = deriv { extraLibs = delete "ffi" extraLibs }
  | pname == "liquid-fixpoint"  = deriv { buildTools = "ocaml":buildTools }
  | pname == "llvm-base"        = deriv { extraLibs = "llvm":extraLibs }
  | pname == "llvm-general"     = deriv { doCheck = False }
  | pname == "llvm-general-pure"= deriv { doCheck = False }
  | pname == "MFlow"            = deriv { buildTools = "cpphs":buildTools }
  | pname == "multiarg"         = deriv { buildDepends = "utf8String":buildDepends }
  | pname == "mime-mail"        = deriv { extraFunctionArgs = ["sendmail ? \"sendmail\""], phaseOverrides = mimeMailConfigureFlags }
  | pname == "mysql"            = deriv { buildTools = "mysqlConfig":buildTools, extraLibs = "zlib":extraLibs }
  | pname == "ncurses"          = deriv { phaseOverrides = ncursesPatchPhase }
  | pname == "Omega"            = deriv { testDepends = delete "stdc++" testDepends }
  | pname == "OpenAL"           = deriv { extraLibs = "openal":extraLibs }
  | pname == "OpenGL"           = deriv { extraLibs = "mesa":"libX11":extraLibs }
  | pname == "pandoc"           = deriv { buildDepends = "alex":"happy":buildDepends }
  | pname == "pango"            = deriv { extraLibs = "pkgconfig":"libc":extraLibs }
  | pname == "pcap"             = deriv { extraLibs = "libpcap":extraLibs }
  | pname == "persistent"       = deriv { extraLibs = "sqlite3":extraLibs }
  | pname == "poppler"          = deriv { extraLibs = "libc":extraLibs }
  | pname == "purescript"       = deriv { testDepends = "nodejs":testDepends }
  | pname == "repa-algorithms"  = deriv { extraLibs = "llvm":extraLibs }
  | pname == "repa-examples"    = deriv { extraLibs = "llvm":extraLibs }
  | pname == "saltine"          = deriv { extraLibs = map (\x -> if x == "sodium" then "libsodium" else x) extraLibs }
  | pname == "SDL-image"        = deriv { extraLibs = "SDL_image":extraLibs }
  | pname == "SDL-mixer"        = deriv { extraLibs = "SDL_mixer":extraLibs }
  | pname == "SDL-ttf"          = deriv { extraLibs = "SDL_ttf":extraLibs }
  | pname == "sloane"           = deriv { phaseOverrides = sloanePostInstall }
  | pname == "structured-haskell-mode" = deriv { buildTools = "emacs":buildTools, phaseOverrides = structuredHaskellModePostInstall }
  | pname == "svgcairo"         = deriv { extraLibs = "libc":extraLibs }
  | pname == "terminfo"         = deriv { extraLibs = "ncurses":extraLibs }
  | pname == "threadscope"      = deriv { configureFlags = "--ghc-options=-rtsopts":configureFlags }
  | pname == "thyme"            = deriv { buildTools = "cpphs":buildTools }
  | pname == "tz"               = deriv { extraFunctionArgs = ["pkgs_tzdata"], phaseOverrides = "preConfigure = \"export TZDIR=${pkgs_tzdata}/share/zoneinfo\";" }
  | pname == "vacuum"           = deriv { extraLibs = "ghcPaths":extraLibs }
  | pname == "vector"           = deriv { configureFlags = "${stdenv.lib.optionalString stdenv.isi686 \"--ghc-options=-msse2\"}":configureFlags }
  | pname == "wxc"              = deriv { extraLibs = "wxGTK":"mesa":"libX11":extraLibs, phaseOverrides = wxcPostInstall version }
  | pname == "wxcore"           = deriv { extraLibs = "wxGTK":"mesa":"libX11":extraLibs }
  | pname == "X11" && version >= Version [1,6] []
                                = deriv { extraLibs = "libXinerama":"libXext":"libXrender":extraLibs }
  | pname == "X11"              = deriv { extraLibs = "libXinerama":"libXext":extraLibs }
  | pname == "X11-xft"          = deriv { extraLibs = "pkgconfig":"freetype":"fontconfig":extraLibs
                                        , configureFlags = "--extra-include-dirs=${freetype}/include/freetype2":configureFlags
                                        }
  | pname == "xmonad"           = deriv { phaseOverrides = xmonadPostInstall }
  | otherwise                   = deriv

cudaConfigurePhase :: String
cudaConfigurePhase = unlines
  [ "# The cudatoolkit provides both 64 and 32-bit versions of the"
  , "# library. GHC's linker fails if the wrong version is found first."
  , "# We solve this by eliminating lib64 from the path on 32-bit"
  , "# platforms and putting lib64 first on 64-bit platforms."
  , "configurePhase = ''"
  , "  for i in Setup.hs Setup.lhs; do"
  , "    test -f $i && ghc --make $i"
  , "  done"
  , "  for p in $extraBuildInputs $propagatedNativeBuildInputs; do"
  , "    if [ -d \"$p/include\" ]; then"
  , "      extraLibDirs=\"$extraLibDirs --extra-include-dir=$p/include\""
  , "    fi"
  , "    for d in ${if stdenv.is64bit then \"lib64 lib\" else \"lib\"}; do"
  , "      if [ -d \"$p/$d\" ]; then"
  , "        extraLibDirs=\"$extraLibDirs --extra-lib-dir=$p/$d\""
  , "      fi"
  , "    done"
  , "  done"
  , "  ./Setup configure --verbose --prefix=\"$out\" $libraryProfiling $extraLibDirs $configureFlags"
  , "'';"
  ]

ghcModPostInstall :: String -> Version -> String
ghcModPostInstall pname version = unlines
  [ "configureFlags = \"--datasubdir=" ++ pname ++ "-" ++ display version ++ "\";"
  , "postInstall = ''"
  , "  cd $out/share/$pname-$version"
  , "  make"
  , "  rm Makefile"
  , "  cd .."
  , "  ensureDir \"$out/share/emacs\""
  , "  mv $pname-$version emacs/site-lisp"
  , "'';"
  ]

wxcPostInstall :: Version -> String
wxcPostInstall version = unlines
  [ "postInstall = ''"
  , "  cp -v dist/build/libwxc.so." ++ display version ++ " $out/lib/libwxc.so"
  , "'';"
  ]

cabalInstallPostInstall :: String
cabalInstallPostInstall = unlines
  [ "postInstall = ''"
  , "  mkdir $out/etc"
  , "  mv bash-completion $out/etc/bash_completion.d"
  , "'';"
  ]

darcsInstallPostInstall :: String
darcsInstallPostInstall = unlines
  [ "postInstall = ''"
  , "  mkdir -p $out/etc/bash_completion.d"
  , "  mv contrib/darcs_completion $out/etc/bash_completion.d/darcs"
  , "'';"
  ]

highlightingKatePostProcessing :: Derivation -> Derivation
highlightingKatePostProcessing deriv@(MkDerivation {..}) = deriv
  { phaseOverrides = "prePatch = \"sed -i -e 's|regex-pcre-builtin >= .*|regex-pcre|' highlighting-kate.cabal\";"
  , buildDepends = "regex-pcre" : filter (/="regex-pcre-builtin") buildDepends
  }

xmonadPostInstall :: String
xmonadPostInstall = unlines
  [ "postInstall = ''"
  , "  shopt -s globstar"
  , "  mkdir -p $out/share/man/man1"
  , "  mv \"$out/\"**\"/man/\"*.1 $out/share/man/man1/"
  , "'';"
  , "patches = ["
  , "  # Patch to make xmonad use XMONAD_{GHC,XMESSAGE} (if available)."
  , "  ./xmonad_ghc_var_0.11.patch"
  , "];"
  ]

gitAnnexOverrides :: String
gitAnnexOverrides = unlines
  [ "preConfigure = \"export HOME=$TEMPDIR\";"
  , "installPhase = \"./Setup install\";"
  , "checkPhase = ''"
  , "  cp dist/build/git-annex/git-annex git-annex"
  , "  ./git-annex test"
  , "'';"
  , "propagatedUserEnvPkgs = [git lsof];"
  ]

ghciPostInstall :: String
ghciPostInstall = unlines
  [ "postInstall = ''"
  , "  ensureDir \"$out/share/ghci\""
  , "  ln -s \"$out/share/$pname-$version/ghci\" \"$out/share/ghci/$pname\""
  , "'';"
  ]

hfusePreConfigure :: String
hfusePreConfigure = unlines
  [ "preConfigure = ''"
  , "  sed -i -e \"s@  Extra-Lib-Dirs:         /usr/local/lib@  Extra-Lib-Dirs:         ${fuse}/lib@\" HFuse.cabal"
  , "'';"
  ]

ghcPathsPatches :: String
ghcPathsPatches = "patches = [ ./ghc-paths-nix.patch ];"

lhs2texPostInstall :: String
lhs2texPostInstall = unlines
  [ "postInstall = ''"
  , "  mkdir -p \"$out/share/doc/$name\""
  , "  cp doc/Guide2.pdf $out/share/doc/$name"
  , "  mkdir -p \"$out/nix-support\""
  , "'';"
  ]

ncursesPatchPhase :: String
ncursesPatchPhase = "patchPhase = \"find . -type f -exec sed -i -e 's|ncursesw/||' {} \\\\;\";"

agdaPostInstall :: String
agdaPostInstall = unlines
  [ "postInstall = ''"
  , "  $out/bin/agda -c --no-main $(find $out/share -name Primitive.agda)"
  , "  $out/bin/agda-mode compile"
  , "'';"
  ]

structuredHaskellModePostInstall :: String
structuredHaskellModePostInstall = unlines
  [ "postInstall = ''"
  , "  emacs -L elisp --batch -f batch-byte-compile \"elisp/\"*.el"
  , "  install -d $out/share/emacs/site-lisp"
  , "  install \"elisp/\"*.el \"elisp/\"*.elc  $out/share/emacs/site-lisp"
  , "'';"
  ]

sloanePostInstall :: String
sloanePostInstall = unlines
  [ "postInstall = ''"
  , "  mkdir -p $out/share/man/man1"
  , "  cp sloane.1 $out/share/man/man1/"
  , "'';"
  ]

mimeMailConfigureFlags :: String
mimeMailConfigureFlags = unlines
  [ "configureFlags = \"--ghc-option=-DMIME_MAIL_SENDMAIL_PATH=\\\"${sendmail}\\\"\";"
  ]

haddockPreCheck :: String
haddockPreCheck = "preCheck = \"unset GHC_PACKAGE_PATH\";"

ghcParserPatchPhase :: String
ghcParserPatchPhase = unlines
  [ "patchPhase = ''"
  , "  substituteInPlace build-parser.sh --replace \"/bin/bash\" \"$SHELL\""
  , "'';"
  ]
