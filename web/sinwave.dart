import 'dart:html';
import 'dart:math';
import 'dart:js';
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';

class Cube{
  var scene,render,shape,cam;
  int width, height;
  double time = 0.0;
  int maxtime = 2000;
  bool paused = false;
  double rspeed = 0.01, speed = 0.02;
  double x = 0.0;
  double thetaDelta = 0.0, phiDelta = 0.0;
  Vector3 offset = new Vector3(0.0,0.0,0.0);
  JsObject controls;
  List<Part> parts = new List<Part>();
  Material mat = new MeshBasicMaterial(color: 0x33FFFF);
  Cube(var c, this.width, this.height, int color, double speed){
    
    this.render = new WebGLRenderer()
      ..setSize(this.width, this.height);
    c.append(this.render.domElement);
    this.cam = new PerspectiveCamera(8.0, this.width/this.height, 1.0, 1000.0)
      ..position.setValues(-1.0, -2.0, 60.0);
    this.scene = new Scene()
      ..add(this.cam);
  }
  void draw(double time){
    this.time += 0.1;
    this.updateCam();
    if(!this.paused && (this.time*1000).round()%500==0){
      Mesh m = new Mesh(new SphereGeometry(0.05), mat);
      m.position.x = this.time*speed*10;
      m.position.y = (sin(this.time/10)-0.5)*4;
      this.scene.add(m);
      parts.add(new Part(m));
    }
    this.render.render(this.scene, this.cam);
    this.render.setClearColorHex(0x020202,1);
    window.requestAnimationFrame((t)=>draw(t));
    List<Part> removed = new List<Part>();
    Iterator i = parts.iterator;
    while(i.moveNext()){
      Part part = i.current;
      if(part != null){
        if(part.timealive > maxtime){
          removed.add(part);
          this.scene.remove(part.mesh);
        } else {
          part.mesh.scale.multiply(new Vector3(0.998,0.998,0.998));
        }
        if(!this.paused){
          part.timealive ++;
        }
      }
    }
    Iterator ri = removed.iterator;
    while(ri.moveNext()){
      parts.remove(ri.current);
    }
  }
  
  void updateCam(){
    this.x += speed;
    this.cam.position.setValues(this.x+80,0.0,60.0); 
    this.cam.lookAt(new Vector3(this.x,-2.0,0.0));
  }
  
  void start(){
    this.draw(0.0);
  }
}

class Part{
  Mesh mesh;
  int timealive = 0;
  Part(Mesh mesh){
    this.mesh = mesh;
  }
}

void main() {
  var el1 = querySelector("#stage1");
  JsObject heightandwidth = new JsObject(context['height'], []);
  int x = heightandwidth.callMethod('height',[]);
  int y = heightandwidth.callMethod('width',[]);
  Cube cube1 = new Cube(el1,y,x,0xff0000,1/40.0);
  cube1.start();
}
