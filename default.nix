{ stdenv
, fetchzip
, lib
, pkgs
, makeWrapper
, jdk21
, libgcc
, maven
}:

stdenv.mkDerivation rec {
  pname = "joern-cli";
  version = "2.0.429";
  src = fetchzip {
    url = "https://github.com/joernio/joern/releases/download/v${version}/joern-cli.zip";
    sha256 = "9nosLhCODjbN/1WD1kmF+FvjUcsfqoJdI/gL+4Ya5sc=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    joernExecutables=( joern joern-parse joern-export joern-flow joern-scan joern-slice )
    joernExecutables+=( c2cpg.sh ghidra2cpg jssrc2cpg.sh javasrc2cpg jimple2cpg kotlin2cpg php2cpg rubysrc2cpg pysrc2cpg )

    mkdir -p $out/lib $out/bin
    cp -ra . $out/lib
    for command in ''${joernExecutables[@]}; do
      ln -sf $out/lib/''${command} $out/bin || true
    done
  '';

  postFixup = ''
    for command in ''${joernExecutables[@]}; do
      wrapProgram $out/lib/''${command} \
        --prefix PATH : ${lib.makeBinPath [ jdk21 libgcc maven ]}
    done
  '';

  meta = with lib; {
    description = "Joern - The Bug Hunter's Workbench";
    longDescription = ''
      Joern is a platform for analyzing source code, bytecode, and binary executables.
      It generates code property graphs (CPGs), a graph representation of code for cross-language code analysis.
      Code property graphs are stored in a custom graph database.
      This allows code to be mined using search queries formulated in a Scala-based domain-specific query language.
      Joern is developed with the goal of providing a useful tool for vulnerability discovery and research in static program analysis.
    '';
    homepage = "https://joern.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ constexpr12 ];
    platforms = platforms.all;
  };
}
