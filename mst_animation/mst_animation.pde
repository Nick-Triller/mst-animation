import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;

List<Vertex> vertices = new ArrayList<Vertex>();
List<Edge> mst = new ArrayList<Edge>();
int radius = 25;
int maxVelocity = width / 7;
int edgeStrokeWeight = 5;
int initalVertexCount = 25;

void setup() {
  randomSeed(0);
  fullScreen(SPAN);
  
  // Spawn vertices
  vertices = new ArrayList<Vertex>();
  for (int i = 0; i < initalVertexCount; i++) {
    spawnVertex();
  }
}

void draw() {
  clear();
  update();
  display();
}

void update() {
  // Update locations of vertices
  for (Vertex vertex : vertices) {
    vertex.location.add(vertex.velocity);
    int halfRadius = vertex.radius / 2;
    if (vertex.location.x - halfRadius <= 0 || vertex.location.x + halfRadius >= width) {
      vertex.velocity.x *= -1;
    }
    if (vertex.location.y - halfRadius <= 0 || vertex.location.y + halfRadius >= height) {
      vertex.velocity.y *= -1;
    }
  }
  
  // find mst
    mst = findMst();
}

void display() {
  for (Edge edge : mst) {
    strokeWeight(edgeStrokeWeight);
    stroke(edge.getColor());
    line(edge.vertex1.location.x, edge.vertex1.location.y, edge.vertex2.location.x, edge.vertex2.location.y);
  }
  
  for (Vertex vertex : vertices) {
    noStroke();
    fill(204);
    ellipse(vertex.location.x, vertex.location.y, vertex.radius, vertex.radius); 
  }
}

List<Edge> findMst() {
  List<Edge> edges = new ArrayList<Edge>();
  if (vertices.size() == 0) {
    return edges;
  }
  
  List<Vertex> inMst = new LinkedList<Vertex>();
  List<Vertex> todo = new LinkedList<Vertex>(vertices);
  
  // Pick any vertex as first one
  Vertex startVertex = todo.remove(todo.size() - 1);
  inMst.add(startVertex);
  
  while (!todo.isEmpty()) {
    double shortestDist = Double.POSITIVE_INFINITY;
    Vertex next = null;
    Vertex nearestMstVertex = null;
    
    Iterator<Vertex> iterTodo = todo.iterator();
    
    // Find vertex in todo that is nearest to MST
    while (iterTodo.hasNext()) {
      Vertex todoVertex = iterTodo.next();
      
      for (Vertex mstVertex : inMst) {
        double dist = todoVertex.location.dist(mstVertex.location);
        if (next == null || dist < shortestDist) {
          next = todoVertex;
          nearestMstVertex = mstVertex;
          shortestDist = dist;
        }
      }
    }
    
    inMst.add(next);
    todo.remove(next);
    
    Edge edge = new Edge();
    edge.vertex1 = next;
    edge.vertex2 = nearestMstVertex;
    
    edges.add(edge);
  }
  
  return edges;
}

void spawnVertex(PVector location) {
    Vertex vertex = new Vertex();
    vertex.radius = radius;
    vertex.location = location;
    vertex.velocity = new PVector(random(maxVelocity) - maxVelocity / 2, random(maxVelocity) - maxVelocity / 2);
    vertices.add(vertex);
}

void spawnVertex() {
  PVector location = new PVector(random(width - radius) + radius / 2, random(height - radius) + radius / 2);
  spawnVertex(location);
}

void mouseReleased() {
  int x = Math.max(radius, mouseX);
  x = Math.min(x, width - radius);
  int y = Math.max(radius, mouseY);
  y = Math.min(y, height - radius);
  
  PVector location = new PVector(x, y);
  spawnVertex(location);
}

class Vertex {
  PVector location;
  PVector velocity;
  int radius;
  
  void display() {
    fill(204);
    ellipse(location.x, location.y, radius, radius);    
  }
}

class Edge {
  Vertex vertex1;
  Vertex vertex2;
  
  color getColor() {
    // Color depends on length of edge
    int dist = (int) vertex1.location.dist(vertex2.location) / 2;
    int scaled = Math.min(200, Math.max(50, dist));
    System.out.println(scaled);
    return color(scaled + 20, scaled * 2, scaled + 20);
  }
}
