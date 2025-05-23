//enum per revisar cap a quin costat sprite del personatge mira i així saber cap a on ha de saltar
enum Looking
{
  LEFT,
  RIGHT
}

//PLAYER VAR
PVector playerPos;

int playerSize = 45;

float playerSpeedX = 2;
float playerSpeedY = -5;

int playerDir;
int playerLook;

boolean charging = false;
boolean isJumping = false;

int charge = 0;
float jumpTime = 0;

float u = 0.0;

Looking plLook = Looking.LEFT;

curva jump;

float jumpY;

float angle = 0;

//Varaibles Fulla
curva cBezierFulla;
PImage leaf;
float aux = 0.0; // Parámetro "aux" per a recorrer la curva
PVector fulla; //Objecte que recorrerà la curva
PVector pLeaf[];
boolean cooldownL;
float counterL;
int posYVariationL;


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

  // Método para calcular los coeficientes de Bézier
  void calcular_coefsBezier() {
    // C0 = P0
    coefs[0].set(puntos_de_ctrl[0]);
    
    // C1 = -3P0 + 3P1
    coefs[1].set(
      -3 * puntos_de_ctrl[0].x + 3 * puntos_de_ctrl[1].x,
      -3 * puntos_de_ctrl[0].y + 3 * puntos_de_ctrl[1].y
    );
    
    // C2 = 3P0 - 6P1 + 3P2
    coefs[2].set(
      3 * puntos_de_ctrl[0].x - 6 * puntos_de_ctrl[1].x + 3 * puntos_de_ctrl[2].x,
      3 * puntos_de_ctrl[0].y - 6 * puntos_de_ctrl[1].y + 3 * puntos_de_ctrl[2].y
    );
    
    // C3 = -P0 + 3P1 - 3P2 + P3
    coefs[3].set(
      -puntos_de_ctrl[0].x + 3 * puntos_de_ctrl[1].x - 3 * puntos_de_ctrl[2].x + puntos_de_ctrl[3].x,
      -puntos_de_ctrl[0].y + 3 * puntos_de_ctrl[1].y - 3 * puntos_de_ctrl[2].y + puntos_de_ctrl[3].y
    );
  }

  void pintar_curvaSalt() {
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
  
  void pintar_puntos_de_ctrlSalt() {
    strokeWeight(15.0);
    stroke(255, 0, 0);
    for (int i=0; i<4; i++) {
      point(puntos_de_ctrl[i].x, puntos_de_ctrl[i].y);
    }
  }
}

// Calcula la nova posició de la fulla en la curva
void calNovaPosFulla() {
  if (fulla == null || cBezierFulla == null) return;
  
  // Calcul de la posició en la curva
  float u = aux;
  float x = cBezierFulla.coefs[0].x +
            cBezierFulla.coefs[1].x * u +
            cBezierFulla.coefs[2].x * u * u +
            cBezierFulla.coefs[3].x * u * u * u;
            
  float y = cBezierFulla.coefs[0].y +
            cBezierFulla.coefs[1].y * u +
            cBezierFulla.coefs[2].y * u * u +
            cBezierFulla.coefs[3].y * u * u * u;
  
  fulla.set(x, y);
  
  // Incrementar el parámetro "aux"
  aux += 0.01;
  if (aux >= 1.0) {
    aux = 0.0; // Reiniciar
  }
}

// Dibuja la hoja fulla
void pinta_fulla() {
  if (fulla != null && leaf != null) {
    imageMode(CENTER);
    image(leaf, fulla.x, fulla.y); // Tamaño ajustable
  }
}

void aplicarFiltreBlau(PImage sprite) {
  // Recorrer todos los píxeles
  for(int x = 0; x < sprite.width; x++) {       // Recorre columnas (X)
    for(int y = 0; y < sprite.height; y++) {    // Recorre filas (Y)
      // 1) Obtener el color del píxel actual
      color pixel = sprite.get(x, y);
      float alpha = alpha(pixel);
      
      // Solo procesar píxeles no transparentes
      if(alpha > 0) {
        // 2) Extraer componentes y aplicar fórmula del filtro azul
        float r = red(pixel) * 0.9;    // Reduce componente roja
        float g = green(pixel) * 0.9;   // Reduce componente verde
        float b = blue(pixel) * 2.5;    // Aumenta componente azul
        
        // 3) Crear nuevo color con los valores ajustados
        color nuevoColor = color(
          constrain(r, 0, 255),
          constrain(g, 0, 255),
          constrain(b, 0, 255),
          alpha
        );
        
        // 4) Asignar el nuevo color al píxel
        sprite.set(x, y, nuevoColor);
      }
    }
  }
}

// Nuevo filtro amarillo
void aplicarFiltreGold(PImage sprite) {
 for(int x = 0; x < sprite.width; x++) {       // Recorre columnas (X)
    for(int y = 0; y < sprite.height; y++) {    // Recorre filas (Y)
      // 1) Obtener el color del píxel actual
      color pixel = sprite.get(x, y);
      float alpha = alpha(pixel);
      
      // Solo procesar píxeles no transparentes
      if(alpha > 0) {
        // 2) Extraer componentes y aplicar fórmula del filtro azul
        float r = red(pixel) * 2.7;    // Reduce componente roja
        float g = green(pixel) * 2.3;   // Reduce componente verde
        float b = blue(pixel) * 1.4;    // Aumenta componente azul
        
        // 3) Crear nuevo color con los valores ajustados
        color nuevoColor = color(
          constrain(r, 0, 255),
          constrain(g, 0, 255),
          constrain(b, 0, 255),
          alpha
        );
        
        // 4) Asignar el nuevo color al píxel
        sprite.set(x, y, nuevoColor);
      }
    }
  }
}

PVector p[];//array de vectores para el salto


//PLAYER SPRITES

PImage toddR;
PImage toddL;
PImage toddChargingR;
PImage toddChargingL;
PImage toddJumpR;
PImage toddJumpL;

//Variables de imatges pel canvi de skin amb les LUTs
PImage ToddRBlue, ToddLBlue, ToddRChargingBlue, ToddLChargingBlue, toddJumpRBlue, toddJumpLBlue;
PImage ToddRGold, ToddLGold, ToddRChargingGold, ToddLChargingGold, toddJumpRGold, toddJumpLGold;
int skinMode = 1; //1 = skin normal, 2 = skin blava, 3 = skin daurada


//TERRENY VAR

PImage fondo;

int room = 1;

boolean changingRoom = false;
float jumpSpeedWhenChanged = 0;

float obsX1[];//array de posicions x del terreny sala 1
float obsY1[];//array de posicions y del terreny sala 1
float obsSizeX1[];// tamany X dels obstacles sala 1
float obsSizeY1[];// tamany Y dels obstacles sala 1

float obsX2[];//array de posicions x del terreny sala 2
float obsY2[];//array de posicions y del terreny sala 2
float obsSizeX2[];// tamany X dels obstacles sala 2
float obsSizeY2[];// tamany Y dels obstacles sala 2

float obsX3[];//array de posicions x del terreny sala 3
float obsY3[];//array de posicions y del terreny sala 3
float obsSizeX3[];// tamany X dels obstacles sala 3
float obsSizeY3[];// tamany Y dels obstacles sala 3

int numTerr;

void setup()
{
  
  size(500, 500);
  
  imageMode(CENTER);
  rectMode(CENTER);
  //Set imatges del player
  toddR = loadImage("rightIdle.png");
  toddL = loadImage("leftIdle.png");
  toddChargingR = loadImage("rightPrepared.png");
  toddChargingL = loadImage("leftPrepared.png");
  toddJumpR = loadImage("rightJumping.png");
  toddJumpL = loadImage("leftJumping.png");
  
  //Set imatges del player a les seves skins per despres canviar-les amb les LUT
  ToddRBlue = loadImage("rightIdle.png");
  ToddLBlue = loadImage("leftIdle.png");
  ToddRChargingBlue = loadImage("rightPrepared.png");
  ToddLChargingBlue = loadImage("leftPrepared.png");
  toddJumpLBlue = loadImage("leftJumping.png");
  toddJumpRBlue = loadImage("rightJumping.png");

  
  ToddRGold = loadImage("rightIdle.png");
  ToddLGold = loadImage("leftIdle.png");
  ToddRChargingGold = loadImage("rightPrepared.png");
  ToddLChargingGold = loadImage("leftPrepared.png");
  toddJumpLGold = loadImage("leftJumping.png");
  toddJumpRGold = loadImage("rightJumping.png");

 
  fondo = loadImage("fondo.png");
  fondo.resize(width,height);
  
  leaf = loadImage("leaf.png");
  pLeaf = new PVector[4];
  pLeaf[0] = new PVector(0, 300);
  pLeaf[1] = new PVector(100, 200);
  pLeaf[2] = new PVector(200, 400);
  pLeaf[3] = new PVector(500, 300);
  cBezierFulla = new curva(pLeaf);
  fulla = new PVector(pLeaf[0].x, pLeaf[0].y);
  cBezierFulla.calcular_coefsBezier();
  cooldownL = true;
  //counterL;
  posYVariationL = (int)random(-150,100);
  
  playerPos = new PVector(width/2, height/2);
  playerDir = 0;
  
  obsX1 = new float[4];
  obsY1 = new float[4];
  obsSizeX1 = new float[4];
  obsSizeY1 = new float[4];
  
  numTerr = 4;
  
  obsX1[0] = 250;
  obsY1[0] = 475;
  obsSizeX1[0] = 500;
  obsSizeY1[0] = 50;
  
  obsX1[1] = 62.5;
  obsY1[1] = 400;
  obsSizeX1[1] = 125;
  obsSizeY1[1] = 200;
  
  obsX1[2] = 437.5;
  obsY1[2] = 400;
  obsSizeX1[2] = 125;
  obsSizeY1[2] = 200;
  
  obsX1[3] = 250;
  obsY1[3] = 175;
  obsSizeX1[3] = 150;
  obsSizeY1[3] = 50;
  
  obsX2 = new float[4];
  obsY2 = new float[4];
  obsSizeX2 = new float[4];
  obsSizeY2 = new float[4];
  
  obsX2[0] = 50;
  obsY2[0] = 485;
  obsSizeX2[0] = 100;
  obsSizeY2[0] = 50;
  
  obsX2[1] = 300;
  obsY2[1] = 375;
  obsSizeX2[1] = 100;
  obsSizeY2[1] = 50;
  
  obsX2[2] = 450;
  obsY2[2] = 250;
  obsSizeX2[2] = 100;
  obsSizeY2[2] = 50;
  
  obsX2[3] = 250;
  obsY2[3] = 100;
  obsSizeX2[3] = 150;
  obsSizeY2[3] = 50;
  
  obsX3 = new float[4];
  obsY3 = new float[4];
  obsSizeX3 = new float[4];
  obsSizeY3 = new float[4];
  
  p = new PVector[4];
 
  aplicarFiltreBlau(ToddRBlue);
  aplicarFiltreBlau(ToddLBlue);
  aplicarFiltreBlau(ToddRChargingBlue);
  aplicarFiltreBlau(ToddLChargingBlue);
  aplicarFiltreBlau(toddJumpLBlue);
  aplicarFiltreBlau(toddJumpRBlue);


  aplicarFiltreGold(ToddRGold);
  aplicarFiltreGold(ToddLGold);
  aplicarFiltreGold(ToddRChargingGold);
  aplicarFiltreGold(ToddLChargingGold);
  aplicarFiltreGold(toddJumpLGold);
  aplicarFiltreGold(toddJumpRGold);
}

void draw()
{
  
  image(fondo, width/2, height/2);
  
  //UPDATE
  if (charging)//CARGANDO
  {
    charge++;
    
    if (charge >= 100)
    {
      jump();
    }
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
  
  if (!changingRoom) {
    if (playerPos.y < 0) { // Going up to next room
      changeRoom(1);
    } 
    else if (playerPos.y > height && room > 1) { // Going down to previous room
      changeRoom(-1);
    }
  }
  
  switch(room)
  {
    case 1:
      checkPlayerColl(obsX1, obsY1, obsSizeX1, obsSizeY1);
      break;
    case 2:
      checkPlayerColl(obsX2, obsY2, obsSizeX2, obsSizeY2);
      break;
    case 3:
      checkPlayerColl(obsX3, obsY3, obsSizeX3, obsSizeY3);
      break;
  }
  
  
  
  //RENDERING
  
  pushMatrix();
  translate(playerPos.x, playerPos.y); // Mover al centro
  
  if (charging)
  {
    if (playerLook == 1)
    {
      if(skinMode == 1)
      {
        image(toddChargingR, 0, 0);
      }
      else if(skinMode == 2)
      {
        image(ToddRChargingBlue, 0, 0);
      }
      else if(skinMode == 3)
      {
        image(ToddRChargingGold, 0, 0);
      }
    }
    else
    {
      if(skinMode == 1)
      {
        image(toddChargingL, 0, 0);
      }
      else if(skinMode == 2)
      {
        image(ToddLChargingBlue, 0, 0);
      }
      else if(skinMode == 3)
      {
        image(ToddLChargingGold, 0, 0);
      }
    }
  }
  else if (!isJumping)
  {
    if (playerLook == 1)
    {
      if(skinMode == 1)
      {
        image(toddR, 0, 0);
      }
      else if(skinMode == 2)
      {
        image(ToddRBlue, 0, 0);
      }
      else if(skinMode == 3)
      {
        image(ToddRGold, 0, 0);
      }    
    }
    else
    {
      if(skinMode == 1)
      {
        image(toddL, 0, 0);
      }
      else if(skinMode == 2)
      {
        image(ToddLBlue, 0, 0);
      }
      else if(skinMode == 3)
      {
        image(ToddLGold, 0, 0);
      }
    }
  }
  else
  {
    

    rotate(angle); // Rotar
    
    if (playerLook == 1)
    {
      if(skinMode == 1)
      {
        image(toddJumpR, 0, 0);
      }
      else if(skinMode == 2)
      {
        image(toddJumpRBlue, 0, 0);
      }
      else if(skinMode == 3)
      {
        image(toddJumpRGold, 0, 0);
      } 
    }
    else
    {
      if(skinMode == 1)
      {
        image(toddJumpL, 0, 0);
      }
      else if(skinMode == 2)
      {
        image(toddJumpLBlue, 0, 0);
      }
      else if(skinMode == 3)
      {
        image(toddJumpLGold, 0, 0);
      } 
    }
    
    angle += 0.1;
    
    
  }
  
  popMatrix();
  
  fill(111, 255, 80);
  stroke(111, 255, 80);
  
  
  switch(room)
  {
    case 1:
      for (int i = 0; i < numTerr; i++)
      {
      rect(obsX1[i], obsY1[i], obsSizeX1[i], obsSizeY1[i]);
      }
      break;
    case 2:
      for (int i = 0; i < numTerr; i++)
      {
        rect(obsX2[i], obsY2[i], obsSizeX2[i], obsSizeY2[i]);
      }
      break;
    case 3:
      for (int i = 0; i < numTerr; i++)
      {
        rect(obsX3[i], obsY3[i], obsSizeX3[i], obsSizeY3[i]);
      }
      break;
  }


  
  println(room);
  calNovaPosFulla();
  pinta_fulla();
}

//INPUTS

void keyPressed()
{
  
  switch(keyCode)
  {
    case LEFT:
      playerDir = -1;
      playerLook = -1;
      plLook = Looking.LEFT;
      break;
    case RIGHT:
      playerDir = 1;
      playerLook = 1;
      plLook = Looking.RIGHT;
      break;
  }
  
  if (key == ' ' && !isJumping && !charging && isGrounded()) 
  {     
    charging = true;
  }
  
  //Cal clicar els nº 1, 2, 3 per poder canviar la skin
  if (key == '1')
    skinMode = 1;
  if (key == '2') 
    skinMode = 2;
  if (key == '3') 
    skinMode = 3;
}

void keyReleased()
{
  
  switch(keyCode)
  {
    case LEFT:
      playerDir = 0;
      break;
    case RIGHT:
      playerDir = 0;
      break;
    
  }
  
  if (key == ' ')
  {
    
    if (!isJumping && isGrounded())
    {
      jump();
    }
    
  }

}

//FUNCTIONS

void jump()
{
  
  jumpY = playerPos.y;
  
  if (isJumping)
    return;
  charging = false;
  isJumping = true;
  
  u = 0.0;
  
  jumpTime = 1.5/charge;
  
  println("jump time is: " + jumpTime);
  
  jumpCalc();
}

void jumpCalc()
{
  
  
  if (playerDir == 0)
  {
    p[0] = new PVector(playerPos.x, playerPos.y); // Este es el punto de ctrl P0
    p[1] = new PVector(playerPos.x , playerPos.y - charge * 2); // Y este es el P1
    p[2] = new PVector(playerPos.x , playerPos.y - charge * 2); // El P2
    p[3] = new PVector(playerPos.x , playerPos.y); // P3
  }
  else if (plLook == Looking.LEFT)
  {
    p[0] = new PVector(playerPos.x, playerPos.y); // Este es el punto de ctrl P0
    p[1] = new PVector(playerPos.x - (charge - (charge / 2.5)), playerPos.y - charge * 2); // Y este es el P1
    p[2] = new PVector(playerPos.x - (charge + (charge / 2.5)), playerPos.y - charge * 2); // El P2
    p[3] = new PVector(playerPos.x - charge * 2.5, playerPos.y); // P3
  }
  else
  {
    p[0] = new PVector(playerPos.x, playerPos.y); // Este es el punto de ctrl P0
    p[1] = new PVector(playerPos.x + (charge - (charge / 2.5)), playerPos.y - charge * 2); // Y este es el P1
    p[2] = new PVector(playerPos.x + (charge + (charge / 2.5)), playerPos.y - charge * 2); // El P2
    p[3] = new PVector(playerPos.x + charge * 2.5, playerPos.y); // P3
  }
 
  jump = new curva(p);
  jump.calcular_coefs();
  
}

void jumpCalcSwitch()
{
  if (playerDir == 0)
  {
    p[0] = new PVector(playerPos.x,  height+jumpY); // Este es el punto de ctrl P0
    p[1] = new PVector(playerPos.x , height+jumpY - charge * 2); // Y este es el P1
    p[2] = new PVector(playerPos.x , height+jumpY - charge * 2); // El P2
    p[3] = new PVector(playerPos.x , height+jumpY); // P3
  }
  else if (plLook == Looking.LEFT)
  {
    p[0] = new PVector(playerPos.x, height+jumpY); // Este es el punto de ctrl P0
    p[1] = new PVector(playerPos.x - (charge - (charge / 2.5)), height+jumpY - charge * 2); // Y este es el P1
    p[2] = new PVector(playerPos.x - (charge + (charge / 2.5)), height+jumpY - charge * 2); // El P2
    p[3] = new PVector(playerPos.x - charge * 2.5, height+jumpY); // P3
  }
  else
  {
    p[0] = new PVector(playerPos.x, height+jumpY); // Este es el punto de ctrl P0
    p[1] = new PVector(playerPos.x + (charge - (charge / 2.5)), height+jumpY - charge * 2); // Y este es el P1
    p[2] = new PVector(playerPos.x + (charge + (charge / 2.5)), height+jumpY - charge * 2); // El P2
    p[3] = new PVector(playerPos.x + charge * 2.5, height+jumpY); // P3
  }
 
  jump = new curva(p);
  jump.calcular_coefs();
  
}

void checkPlayerColl(float[] obsX, float[] obsY, float[] obsSizeX, float[] obsSizeY) {
  // First check Y collisions (most important for standing)
  checkPlayerCollY(obsX, obsY, obsSizeX, obsSizeY);
  
  // Then check X collisions
  checkPlayerCollX(obsX, obsY, obsSizeX, obsSizeY);
}

void checkPlayerCollY(float[] obsX, float[] obsY, float[] obsSizeX, float[] obsSizeY) {
  float pT = playerPos.y - playerSize/2;
  float pB = playerPos.y + playerSize/2;
  float pL = playerPos.x - playerSize/2;
  float pR = playerPos.x + playerSize/2;

  boolean onGround = false;
  
  for (int i = 0; i < numTerr; i++) {
    float obsT = obsY[i] - obsSizeY[i]/2;
    float obsB = obsY[i] + obsSizeY[i]/2;
    float obsL = obsX[i] - obsSizeX[i]/2;
    float obsR = obsX[i] + obsSizeX[i]/2;
    
    // Check if player is within X bounds of obstacle
    if (pR > obsL && pL < obsR) {
      // Landing on top of platform
      if (pB > obsT && pT < obsT && playerSpeedY <= 0) {
        playerPos.y = obsT - playerSize/2;
        playerSpeedY = 0;
        isJumping = false;
        u = 0;
        onGround = true;
        angle = 0;
      }
      // Hitting bottom of platform
      else if (pT < obsB && pB > obsB && playerSpeedY >= 0) {
        playerPos.y = obsB + playerSize/2;
        playerSpeedY = 0;
      }
    }
  }
  
  // Apply gravity if not on ground
  if (!onGround && !isJumping && !charging) {
    playerSpeedY = -5;
  }
}

void checkPlayerCollX(float[] obsX, float[] obsY, float[] obsSizeX, float[] obsSizeY) {
  float pT = playerPos.y - playerSize/2;
  float pB = playerPos.y + playerSize/2;
  float pL = playerPos.x - playerSize/2;
  float pR = playerPos.x + playerSize/2;

  for (int i = 0; i < numTerr; i++) {
    float obsT = obsY[i] - obsSizeY[i]/2;
    float obsB = obsY[i] + obsSizeY[i]/2;
    float obsL = obsX[i] - obsSizeX[i]/2;
    float obsR = obsX[i] + obsSizeX[i]/2;
    
    // Check if player is within Y bounds of obstacle
    if (pB > obsT && pT < obsB) {
      // Left side collision
      if (pR > obsR && pL < obsR) {
        playerPos.x = obsR + playerSize/2 + 1;
      }
      // Right side collision
      else if (pL < obsL && pR > obsL) {
        playerPos.x = obsL - playerSize/2 - 1;
      }
    }
  }
  
  // Screen boundaries
  playerPos.x = constrain(playerPos.x, playerSize/2, width - playerSize/2);
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
  if (u >= 1.0) {
    u = 1.0; // Clamp to avoid overshooting
    isJumping = false;
  }
  // Segun el estado, nos movemos por una u otra curva
  // Cuando el parametro "u" sea >= 1.0, toca cambiar de curva
    playerPos.x = jump.coefs[0].x + jump.coefs[1].x * u 
               + jump.coefs[2].x * u * u + jump.coefs[3].x * u * u * u;
    playerPos.y = jump.coefs[0].y + jump.coefs[1].y * u 
               + jump.coefs[2].y * u * u + jump.coefs[3].y * u * u * u;
    
    float w = jumpTime;
    
    u += w;
    if (u >= 0.5){
      w = -jumpTime;
    }
    
}

void changeRoom(int direction) {
  changingRoom = true;
  
  // 1. Remember the jump speed if jumping
  if (isJumping) {
    jumpSpeedWhenChanged = jumpTime;
  }
  
  // 2. Change room and reposition player
  room += direction;
  if (direction > 0) {
    playerPos.y = height - 10; // Near bottom of new room
  } else {
    playerPos.y = 10; 
    isJumping = false;
  }
  
  // 3. If jumping, continue with similar motion
  if (isJumping) {
    // Keep same X direction but reduce jump power slightly
    float power = jumpSpeedWhenChanged * 0.9; 
    jumpTime = power;
    jumpCalcSwitch(); // Recalculate curve in new position
  }
  
  changingRoom = false;
}

boolean isGrounded() {
  // Player's bottom edge position
  float playerBottom = playerPos.y + playerSize/2;
  
  // Small threshold to allow for minor floating point inaccuracies
  float groundThreshold = 2.0;
  
  // Check collision with all terrain objects in current room
  switch(room) {
    case 1:
      return checkGroundedWithTerrain(obsX1, obsY1, obsSizeX1, obsSizeY1, playerBottom, groundThreshold);
    case 2:
      return checkGroundedWithTerrain(obsX2, obsY2, obsSizeX2, obsSizeY2, playerBottom, groundThreshold);
    case 3:
      return checkGroundedWithTerrain(obsX3, obsY3, obsSizeX3, obsSizeY3, playerBottom, groundThreshold);
    default:
      return false;
  }
}

boolean checkGroundedWithTerrain(float[] obsX, float[] obsY, float[] obsSizeX, float[] obsSizeY, 
                                float playerBottom, float threshold) {
  float pL = playerPos.x - playerSize/2;
  float pR = playerPos.x + playerSize/2;
  
  for (int i = 0; i < numTerr; i++) {
    float obsT = obsY[i] - obsSizeY[i]/2; // Top of obstacle
    float obsL = obsX[i] - obsSizeX[i]/2;
    float obsR = obsX[i] + obsSizeX[i]/2;
    
    // Check if player is within X bounds of obstacle and just above the top surface
    if (pR > obsL && pL < obsR && 
        playerBottom >= obsT - threshold && 
        playerBottom <= obsT + threshold) {
      return true;
    }
  }
  
  // Also check if player is at bottom of screen (if that counts as ground)
  if (playerBottom >= height - threshold && room == 1) {
    return true;
  }
  
  return false;
}
