


https://pub.dev/packages/serious_python


创建tag

git tag v0.0.1

推送tag到远程

git push origin v0.0.1


 删除本地tag

 git tag -d v1.0.0


 删除远程tag

 git push origin --delete v1.0.0
 




For Android:

```
export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
dart run serious_python:main package app/src -p Android -r -r -r app/src/requirements.txt
```

For iOS:

```
export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
dart run serious_python:main package app/src -p iOS -r -r -r app/src/requirements.txt
```

For macOS:

```
export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
dart run serious_python:main package app/src -p Darwin -r -r -r app/src/requirements.txt
```

For Windows:

```
export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
dart run serious_python:main package app/src -p Windows -r -r -r app/src/requirements.txt
```

For Linux:

```
export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
dart run serious_python:main package app/src -p Linux -r -r -r app/src/requirements.txt
```

更多信息参考：https://github.com/flet-dev/serious-python/tree/main/src/serious_python/example/run_example



Important: to make `serious_python` work in your own Android app:

If you build an App Bundle Edit `android/gradle.properties` and add the flag:

```
android.bundle.enableUncompressedNativeLibs=false
```

If you build an APK Make sure `android/app/src/AndroidManifest.xml` has `android:extractNativeLibs="true"` in the `<application>` tag.

For more information, see the [public issue](https://issuetracker.google.com/issues/147096055).