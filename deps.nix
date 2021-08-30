{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    argon2_elixir = buildMix rec {
      name = "argon2_elixir";
      version = "2.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07am18pbfiii8aqg4zim83hrb8g6rznpyxhzmdnzdrzq7hc2xa2f";
      };

      beamDeps = [ comeonin elixir_make ];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lw3v9kwbbcy1v6ygziiky887gffwwmxvyg4r1v0zm71kzhcgxbs";
      };

      beamDeps = [];
    };

    castore = buildMix rec {
      name = "castore";
      version = "0.1.9";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1j167m2a2l8dhjspscayp3rk26nsj21wj60lxqzv1fn0v65a7hwr";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.5.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "040w1scglvqhcvc1ifdnlcyrbwr0smi00w4xi8h03c99775nllgd";
      };

      beamDeps = [ parse_trans ];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.3.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "012zr4s7b5bipng6yszqxkqr1lcv7imf8gyvxad56jachh1396fh";
      };

      beamDeps = [];
    };

    concurrent_limiter = buildMix rec {
      name = "concurrent_limiter";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sqnb987qwwy4ip7kxh9g7vv5wz61fpv3pbnxpbv9yy073r8z5jk";
      };

      beamDeps = [ telemetry ];
    };

    corsica = buildMix rec {
      name = "corsica";
      version = "1.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ba8ld1m9dpwzjagjsxmjwjnnxm166lk64w7c9i38jhi9ahv6ml1";
      };

      beamDeps = [ plug ];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12mcbyqyxjynzldcfm7kbpxb7l7swqyq0x9c2m6nvjaalzxy8hs6";
      };

      beamDeps = [ cowlib ranch ];
    };

    cowboy_telemetry = buildRebar3 rec {
      name = "cowboy_telemetry";
      version = "0.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1bzhcdq12p837cii2jgvzjyrffiwgm5bsb1pra2an3hkcqrzsvis";
      };

      beamDeps = [ cowboy telemetry ];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.10.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0i4s11sfga2w7i2f2s6chap6jbmklgm9impik5qqgri80bhp2hlv";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.5.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1i0v2ivh4m8kvh9kllxpyws1pj8mqkd6zd8kp8wky2nwx92sylfg";
      };

      beamDeps = [ bunt file_system jason ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "1.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11bxdzywr4pam7l0jpfrknhzlnz9zpgz473m7s7r5mpfd0sk9wmi";
      };

      beamDeps = [];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0m26cpw56gq1q47x1w7p5jy3sxaj5la1l1nq13519b2z2j46bc5f";
      };

      beamDeps = [ erlex ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.12";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0q1i9cbx4l45v3xh7h9vlq4964nwyxw4pxa3dmb7vfsasv22q7ki";
      };

      beamDeps = [];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.6.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1na8agkks1hrwq1lxfj4yd96bvfcs4hk7mbra9z6lli2vanrxr03";
      };

      beamDeps = [];
    };

    elixir_uuid = buildMix rec {
      name = "elixir_uuid";
      version = "1.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ljpb1l9v262k043irj6i6w9fwyqn0b2fj86jyhcwm9mdkma5szp";
      };

      beamDeps = [];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x8c1j62y748ldvlh46sxzv5514rpzm809vxn594vd7y25by5lif";
      };

      beamDeps = [];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.23.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05jsga13jb6rxf2h4amsfg8wsbyxv9nl2f8dn48zvck84iqc9qpm";
      };

      beamDeps = [ earmark_parser makeup_elixir ];
    };

    excoveralls = buildMix rec {
      name = "excoveralls";
      version = "0.13.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "14313qwlvcj4yv3sglhph9r45ycigjd6c2y1881xyp73xsrh1bps";
      };

      beamDeps = [ hackney jason ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p0myxmnjjds8bbg69dd6fvhk8q3n7lb78zd4qvmjajnzgdmw6a1";
      };

      beamDeps = [];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.18.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1igmn69xzj5wpkblg3k9v7wa2fjc2j0cncwx0grk1pag7nqkgxgr";
      };

      beamDeps = [];
    };

    gun = buildRebar3 rec {
      name = "gun";
      version = "2.0.0-rc.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s3r5if4716h70hw0rh0l025ajsazbkph0znin3njkw97j27r7j5";
      };

      beamDeps = [ cowlib ];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.17.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0737vh8jh15s8p4gpjgi79q9ah6i7idhw33jhksmb27ay4jj5hk4";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0fiwkdrbj7mmz449skp7laz2jdwsqn3svddncmicd46gk2m9w218";
      };

      beamDeps = [ hackney ];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y91s7q8zlfqd037c1mhqdhrvrf60l4ax7lzya1y33h5y3sji8hq";
      };

      beamDeps = [ decimal ];
    };

    joken = buildMix rec {
      name = "joken";
      version = "2.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07mwnzzb9slhzqjmd0nbs4dyjkbb3v06km82mhvdbi8fkjkn7cjp";
      };

      beamDeps = [ jose ];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1i8szzpmiqc7xdv0lp38ng9fild7c5182b4pzkx4qbydnfgnr3q7";
      };

      beamDeps = [];
    };

    json_ld = buildMix rec {
      name = "json_ld";
      version = "0.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "09wzk4m417ip0y8kw2zdhidxqi9x96pyjm0zwny6d4q4ybmls328";
      };

      beamDeps = [ httpoison jason rdf ];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1a9cp9zp85yfybhdxapi9haa1yykzq91bw8abmk0qp1z5p05i8fg";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.15.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1j3fdjp915nq44c55gwysscryyqivjnaaign0wman1sb4drw2s6v";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    memento = buildMix rec {
      name = "memento";
      version = "0.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05p9wasbn5v0s2fkh6y9zqzby5c78nss0xsxki9ws7fjamicd3zz";
      };

      beamDeps = [];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "1.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ij7y8s4i0hz280vvhjrnn4kr7fyp4x2vkfr7ldgqj92al7lraam";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0jzmr0x3s6z16c74gvrk9aqc10brn6a1dwa8ywzr2vkhdgb35sq8";
      };

      beamDeps = [];
    };

    oauth2 = buildMix rec {
      name = "oauth2";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rz7j456fi5qmakilfi36zd82w1zpsf3fjbrvkyzk1bkmij866w8";
      };

      beamDeps = [ hackney ];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.5.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y091my7pmhz1hdd2slyil20rkcvxgi2pfzx2j27i8y52x2dck3p";
      };

      beamDeps = [ jason phoenix_html phoenix_pubsub plug plug_cowboy plug_crypto telemetry ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "2.14.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03z8r285znlg25yi47d4l59s7jq58y4dnhvbxgp16npkzykrgmpg";
      };

      beamDeps = [ plug ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wgpa19l6xar0k2m117iz2kq3cw433llp07sqswpf5969y698bf5";
      };

      beamDeps = [];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.11.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xl863l7987a5jxxq6mqj1l7brz2yhd1csfh5xfdrycr0hzn771d";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01q5ny2m75206987xgzjaakskqq8524nhnrakdypmczpvyv168fp";
      };

      beamDeps = [ cowboy cowboy_telemetry plug telemetry ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hizd1lrp8lfz45282z9v05w2z00ydahflj4qgx1yf5zx25572x4";
      };

      beamDeps = [];
    };

    protocol_ex = buildMix rec {
      name = "protocol_ex";
      version = "0.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s8z76jbd0qrz1wqy1qpmrk9ky2bncw9iwfkgkqqd72wa2rxv9bc";
      };

      beamDeps = [];
    };

    qlc = buildMix rec {
      name = "qlc";
      version = "1.0.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0zvpnkavnd62w010gv60jshwpmk2nlznmg77g2csrd3n0xk3jw3z";
      };

      beamDeps = [];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1my7mz3x7a1fmjyin55nn1fr2d2rl3y64qf3kpcidxvxg0kqa7a5";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    stream_data = buildMix rec {
      name = "stream_data";
      version = "0.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wg2p5hwf7qmkwsc1i3q7h558f7sr9f13y8i6kds9bb9q3pd4aq1";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "0.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1vzw2cmdjyqcc82d6413h4c2nbkj26aifljqgdnj0snsknyij51d";
      };

      beamDeps = [];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ap0ndp2mh9vldwhk2482gcq1mj7fczvcqqkcj7clpwzasjp84xz";
      };

      beamDeps = [ castore gun hackney jason mime telemetry ];
    };

    ueberauth = buildMix rec {
      name = "ueberauth";
      version = "0.6.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0q0vz7vlbw66a32d7yij3p5l4a59bi0sygiynn8na38ll7c97hmg";
      };

      beamDeps = [ plug ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };
  };
in self

