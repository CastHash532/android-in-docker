# android-in-docker
Android developement environement with android sdk, ndk, emulator and flutter/kotlin support

#### first install vscode remote server:
follow these steps [here](https://github.com/CastHash532/vscode-in-docker)    
    
#### run Android developement container with vscode mounted in:
```bash
docker run --privileged -d \
            -p 8080:8080 -p 8888:5901 -p 9080:22 \
            -v /bin/vscode:/bin/vscode -v $(pwd)/sdk:/opt/android-sdk \
            -it thyrlian/android-sdk-vnc /bin/vscode/code-server --auth none
```
