# About
The project is only made to play with tcp socket connection and flutter framework. No conventions or protocols are followed during data transactions.

<br>

# Features

<ul>
  <li> 
    <p>Both app(dart) and server(python3) are built with standard library. No dependencies</p>
  </li>
    <li> 
    <p>Server mimics the properties "WebSocket" (clients connect with server using tcp and the connecting is kept alive for the whole time)</p>
  </li>
    <li> 
    <p>Supports UTF-8</p>
  </li>
    <li> 
    <p>Using tunneling software like "NGROK" the server can be assessed from public network (unsafe. data over the packets are not encrypted)</p>
  </li>

</ul>

<br>

# Demo
During this demonstration "Flutter 3.7.7" and "Python 3.10" are used on "Ubuntu 22.10".
<ul>
    <li>
      <p> <h2>Login</h2> </p>
      <img src="demo/1.png" width="90%">
    </li>
    <li>
      <p> <h2>After Successful Connection</h2> </p>
      <img src="demo/2.png" width="90%">
    </li>
    <li>
      <p> <h2>Searching for Another User By Name</h2> </p>
      <img src="demo/3.png" width="90%">
    </li>
    <li>
      <p> <h2>Sending Message</h2> </p>
      <img src="demo/4.png" width="90%">
    </li>
    <li>
      <p> <h2>Messaging From Both Sides</h2> </p>
      <img src="demo/5.png" width="90%">
    </li>


</ul>

<br>

# Steps To Build

<ul>
  <li> 
    <p>Install <a href="https://docs.flutter.dev/get-started/install">Flutter</a>.</p>
  </li>
  <li> 
    <p>Install <a href="https://developer.android.com/studio">Android Studio</a>.</p>
  </li>
  <li> 
    <p>Install <a href="https://www.jetbrains.com/pycharm/">PyCharm</a>.</p>
  </li>
  <li> 
    <p>Install plugins for android studio.</p>
  </li>
  <li> 
    <p>Create new project in both pycharm and flutter(android studio).</p>
  </li>
  <li> 
    <p>Copy codes of server.py to pycharm project and main.dart(flutter app source) to flutter project.</p>
  </li>
  <li> 
    <p>Configure android virtual devices and connect to server using IP "10.0.2.2" if server is running on same computer. Port is 40000. User name must be unique.</p>
  </li>
  <li> 
    <p>If you want to test the app from physical android device make sure to follow this <a href="https://stackoverflow.com/questions/55603979/why-cant-a-flutter-application-connect-to-the-internet-when-installing-app-rel">link </a>.</p>
  </li>
</ul>

<br>
