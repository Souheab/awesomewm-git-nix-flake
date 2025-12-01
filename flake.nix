{
  description = "AwesomeWM git flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    awesome-src = {
      url = "github:awesomewm/awesome";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, awesome-src }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          lua = pkgs.lua5_3;
          luaEnv = lua.withPackages (ps: [ ps.lgi ps.ldoc ]);
        in
        rec {
          awesome-git = pkgs.stdenv.mkDerivation rec {
            pname = "awesome";
            version = "git-${builtins.substring 0 7 awesome-src.rev}";

            src = awesome-src;

            nativeBuildInputs = with pkgs; [
              cmake
              doxygen
              imagemagick
              makeWrapper
              pkg-config
              xmlto
              docbook_xml_dtd_45
              docbook_xsl
              findXMLCatalogs
              asciidoctor
              gobject-introspection
              git
            ];

            buildInputs = with pkgs; [
              cairo
              librsvg
              dbus
              gdk-pixbuf
              luaEnv
              xorg.libpthreadstubs
              libstartup_notification
              libxdg_basedir
              lua
              net-tools
              pango
              xorg.xcbutilcursor
              xorg.libXau
              xorg.libXdmcp
              xorg.libxcb
              xorg.libxshmfence
              xorg.xcbutil
              xorg.xcbutilimage
              xorg.xcbutilkeysyms
              xorg.xcbutilrenderutil
              xorg.xcbutilwm
              libxkbcommon
              xcbutilxrm
              hicolor-icon-theme
            ];

            cmakeFlags = [
              "-DOVERRIDE_VERSION=${version}"
              "-DLUA_LIBRARY=${lua}/lib/liblua.so"
              "-DLUA_INCLUDE_DIR=${lua}/include"
            ];

            GI_TYPELIB_PATH = "${pkgs.pango.out}/lib/girepository-1.0";
            LUA_CPATH = "${luaEnv}/lib/lua/${lua.luaversion}/?.so";
            LUA_PATH = "${luaEnv}/share/lua/${lua.luaversion}/?.lua;;";
            
            FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ ]; };

            postPatch = ''
              patchShebangs tests/examples/_postprocess.lua
            '';

            postInstall = ''
              mv "$out/bin/awesome" "$out/bin/.awesome-wrapped"
              makeWrapper "$out/bin/.awesome-wrapped" "$out/bin/awesome" \
                --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
                --add-flags '--search ${luaEnv}/lib/lua/${lua.luaversion}' \
                --add-flags '--search ${luaEnv}/share/lua/${lua.luaversion}' \
                --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH"

              wrapProgram $out/bin/awesome-client \
                --prefix PATH : "${pkgs.which}/bin"
            '';

            meta = with pkgs.lib; {
              description = "Highly configurable, dynamic window manager for X";
              homepage = "https://awesomewm.org/";
              license = licenses.gpl2Plus;
              platforms = platforms.linux;
            };
          };
          default = awesome-git;
        });

      overlays.default = final: prev: {
        awesome-git = self.packages.${prev.system}.default;
      };
    };
}
