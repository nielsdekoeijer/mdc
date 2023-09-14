zig build-lib -dynamic -fPIC -lc -I$(python3 -c "import sysconfig; print(sysconfig.get_path('include'))") -OReleaseFast src/main.zig
zig build-lib -ofmt=c -lc -I$(python3 -c "import sysconfig; print(sysconfig.get_path('include'))") ./src/main.zig 
mv libmain.so mdc.so
