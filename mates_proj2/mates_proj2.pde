//enum per revisar cap a quin costat sprite del personatge mira i així saber cap a on ha de saltar
enum Looking
{
  LEFT,
  RIGHT
}

//PLAYER VAR
PVector playerPos;

int playerSize = 32;

float playerSpeedX = 2;
float playerSpeedY = -3;

int playerDir;
int playerLook;

boolean charging = false;
boolean isJumping = false;

int charge = 0;

float u = 0.0;

Looking plLook = Looking.LEFT;

curva jump;

class curva {
  // Atributos
  PVector[] puntos_de_ctrl;
  PVector[] coefs;
  // Constructor
  curva(PVector[] p) {
    // Reservamos memoria
    puntos_de_ctrl = new PVector[4];
    coefs = new PVector[4];
    // Inicializamos
    for (int i=0; i<4; i++) {
      puntos_de_ctrl[i]=new PVector(0.0, 0.0);
      coefs[i]=new PVector(0.0, 0.0);
      // Copiamos los puntos recibidos
      puntos_de_ctrl[i]=p[i];
    }
  }
  // Metodos
  void calcular_coefs() {
    // Utilizando la matriz de interpolación
    // Que son 4 ecuaciones...calculamos las C's
    // Y cada ecuacion se resuelve
    // dos veces, osea para X e Y (estamos en 2D)
    // C0 = P0
    coefs[0].x = puntos_de_ctrl[0].x;
    coefs[0].y = puntos_de_ctrl[0].y;
    // C1 = -5.5P0+9P1-4.5P2+P3
    coefs[1].x = -5.5*puntos_de_ctrl[0].x
      +9.0*puntos_de_ctrl[1].x
      -4.5*puntos_de_ctrl[2].x
      +puntos_de_ctrl[3].x;
    coefs[1].y = -5.5*puntos_de_ctrl[0].y
      +9.0*puntos_de_ctrl[1].y
      -4.5*puntos_de_ctrl[2].y
      +puntos_de_ctrl[3].y;
    // C2 = 9P0-22.5P1+18P2-4.5P3
    coefs[2].x = 9.0*puntos_de_ctrl[0].x
      -22.5*puntos_de_ctrl[1].x
      +18.0*puntos_de_ctrl[2].x
      -4.5*puntos_de_ctrl[3].x;
    coefs[2].y = 9.0*puntos_de_ctrl[0].y
      -22.5*puntos_de_ctrl[1].y
      +18.0*puntos_de_ctrl[2].y
      -4.5*puntos_de_ctrl[3].y;
    // C3 = -4.5P0+13.5P1-13.5P2+4.5P3
    coefs[3].x = -4.5*puntos_de_ctrl[0].x
      +13.5*puntos_de_ctrl[1].x
      -13.5*puntos_de_ctrl[2].x
      +4.5*puntos_de_ctrl[3].x;
    coefs[3].y = -4.5*puntos_de_ctrl[0].y
      +13.5*puntos_de_ctrl[1].y
      -13.5*puntos_de_ctrl[2].y
      +4.5*puntos_de_ctrl[3].y;
  }

  void pintar_curva() {
    float x, y;
    // Pintara los puntos de control
    // Tambien pintara a la curva
    // Podemos emplear puntos para hacerlo
    // Caracteristicas de pintado
    strokeWeight(5); // 5 pixeles de grueso para los puntos
    stroke(255, 255, 0); // Curva de color amarillo
    for (float inc_u=0.0; inc_u<1.0; inc_u+=0.1) { // 100 vueltas
      // Calcular X
      x = coefs[0].x + coefs[1].x * inc_u +
        coefs[2].x * inc_u * inc_u +
        coefs[3].x * inc_u * inc_u * inc_u;
      // Calcular Y
      y = coefs[0].y + coefs[1].y * inc_u +
        coefs[2].y * inc_u * inc_u +
        coefs[3].y * inc_u * inc_u * inc_u;
      // Pintar un "puntito" en esa coord XYZ
      point(x, y);
    }
  }
  
  void pintar_puntos_de_ctrl() {
    strokeWeight(15.0);
    stroke(255, 0, 0);
    for (int i=0; i<4; i++) {
      point(puntos_de_ctrl[i].x, puntos_de_ctrl[i].y);
    }
  }
}

PVector p[];//array de vectores para el salto

//PLAYER SPRITES
PImage toddR;
PImage toddL;
PImage toddChargingR;
PImage toddChargingL;


//TERRENY VAR

float obsX;//array de posicions x del terreny
float obsY;//array de posicions y del terreny
float obsSizeX;// tamany X dels obstacles
float obsSizeY;// tamany Y dels obstacles

void setup()
{
  
  size(500, 500);
  
  imageMode(CENTER);
  rectMode(CENTER);
  
  toddR = loadImage("toddR.png");
  toddL = loadImage("toddL.png");
  toddChargingR = loadImage("toddChargingR.png");
  toddChargingL = loadImage("toddChargingL.png");
  
  playerPos = new PVector(width/2, height/2);
  playerDir = 0;
  
  obsX = 250;
  obsY = 450;
  obsSizeX = 500;
  obsSizeY = 100;
  
  p = new PVector[4];
  
  // Ventana
  size(500, 500);
  // Inventarnos 1a curva --> p(u)
  // Invertarnos sus puntos de control
    
}

void draw()
{
  
  background(0);
  
  //UPDATE
  
  if (charging)//CARGANDO
  {
    charge++;
  }
  else
  {
    if (isJumping)//SALTANDO
    {
      playerJumpCalc();
    }
    else//CAMINANDO/QUIETO
    {
      playerPos.x += playerDir * playerSpeedX;
      charge = 0;
    }
  }
  
  playerPos.y -= playerSpeedY;
  
  checkPlayerCollY();
  
  
  //RENDERING
  if (charging)
  {
    if (playerLook == 1)
    {
      image(toddChargingR, playerPos.x, playerPos.y);
    }
    else
    {
      image(toddChargingL, playerPos.x, playerPos.y);
    }
  }
  else
  {
    if (playerLook == 1)
    {
      image(toddR, playerPos.x, playerPos.y);
    }
    else
    {
      image(toddL, playerPos.x, playerPos.y);
    }
  }
  
  fill(111, 255, 80);
  rect(250, 450, 500, 100);
  
  println(charge);

}

//INPUTS
void keyPressed()
{
  
  if (key == 'd' || key == 'D')
  {
      playerDir = 1;
      playerLook = 1;
      plLook = Looking.RIGHT;
  }
  else if (key == 'a' || key == 'A')
  {
      playerDir = -1;
      playerLook = -1;
      plLook = Looking.LEFT;
  }
  
  if (key == ' ' && isGrounded())
  {
    charging = true;
  }
  
}

void keyReleased()
{
  
  if (key == 'd' || key == 'D')
  {
      playerDir = 0;
  }
  else if (key == 'a' || key == 'A')
  {
      playerDir = 0;
  }
  
  if (key == ' ')
  {
    charging = false;
    isJumping = true;
    
    if (plLook == Looking.LEFT)
    {
      p[0] = new PVector(playerPos.x, playerPos.y); // Este es el punto de ctrl P0
      p[1] = new PVector(playerPos.x - 50, playerPos.y - 100); // Y este es el P1
      p[2] = new PVector(playerPos.x - 100, playerPos.y - 100); // El P2
      p[3] = new PVector(playerPos.x - 150, playerPos.y); // P3
    }
    else
    {
      p[0] = new PVector(playerPos.x, playerPos.y); // Este es el punto de ctrl P0
      p[1] = new PVector(playerPos.x + 50, playerPos.y - 100); // Y este es el P1
      p[2] = new PVector(playerPos.x + 100, playerPos.y - 100); // El P2
      p[3] = new PVector(playerPos.x + 150, playerPos.y); // P3
    }
 
  
    jump = new curva(p);
    jump.calcular_coefs();
    
  }

}

//FUNCTIONS

void checkPlayerCollY()
{
  // calc pj limits
  float pT = playerPos.y - playerSize/2;
  float pB = playerPos.y + playerSize/2;
 
  float obsT = obsY - obsSizeY/2;
  float obsB = obsY + obsSizeY/2;
 
  if(pB > obsT && pT < obsB) 
  {
    playerPos.y = obsT - playerSize/2; 
    playerSpeedY = 0; 
    isJumping = false;
    u = 0;
  }

}

void checkPlayerCollR()
{
  // calc pj limits
  float pL = playerPos.x - playerSize/2;
  float pR = playerPos.x + playerSize/2;
 
  float obsL = obsX - obsSizeX/2;
  float obsR = obsX + obsSizeX/2;
 
  if(pR > obsL && pL < obsR) 
  {
    //moviment cap a fora del obstacle
  }

}

boolean isGrounded() {
  float pBottom = playerPos.y + playerSize/2;
  float obsTop = obsY - obsSizeY/2;
  return (abs(pBottom - obsTop) < 1); // Close enough to ground
}

float getMagnitude(PVector v)
{
  return sqrt(v.x*v.x + v.y*v.y);
}

void normalizePV(PVector v)
{
  float mag = getMagnitude(v);
  
  if(mag != 0)
  {
    v.x /= mag;
    v.y /= mag;
  }
}

void playerJumpCalc()
{
  // Segun el estado, nos movemos por una u otra curva
  // Cuando el parametro "u" sea >= 1.0, toca cambiar de curva
    playerPos.x = jump.coefs[0].x +
    jump.coefs[1].x * u +
    jump.coefs[2].x * u * u +
    jump.coefs[3].x * u * u * u;
    playerPos.y = jump.coefs[0].y +
    jump.coefs[1].y * u +
    jump.coefs[2].y * u * u +
    jump.coefs[3].y * u * u * u;
    
    float w = 0.01;
    
    u += w;
    if (u >= 0.5){
      w = -0.01;
    }
    
}
