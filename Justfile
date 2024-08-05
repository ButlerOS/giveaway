serve:
  ghcid --command "cabal repl --enable-multi-repl exe:giveaway lib:giveaway" -W --test Main.main

fmt:
  cabal-gild --io ./*.cabal
  fourmolu -i .
