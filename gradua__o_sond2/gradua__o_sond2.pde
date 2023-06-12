import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;


import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer backgroundMusic;
AudioSample pointSound;
AudioSample gameOverSound;

PImage backgroundImage;
PImage playerImage;
PImage playerImage1;
PImage playerImage2;
PImage targetImage;
PImage enemyImage;

float enemyAcceleration = 0.1; // Taxa de aceleração dos inimigos
int frameCount = 0; 
int playerImageIndex1 = 0; 
int playerImageIndex = 1; // Índice do sprite atual do playerImage2 = aluno3
int score; // Pontuação do jogador
int playerX, playerY; // Posição do jogador
int playerSize; // Tamanho do jogador
int targetX, targetY; // Posição do objetivo (vermelho)
int targetSize; // Tamanho do objetivo (vermelho)
int enemySize; // Tamanho do inimigo (roxo)
int playerSpeed; // Velocidade de movimento do jogador
int enemySpeed; // Velocidade de movimento do inimigo
boolean gameOver; // Flag para indicar se o jogo acabou
boolean gameStarted; // Flag para indicar se o jogo começou
boolean showCredits; // Flag para indicar se está sendo exibida a tela de Historia
boolean showHistoria;// Flag para indicar se está sendo exibida a tela de créditos
boolean chooseColor; // Flag para indicar se está sendo exibida a tela de seleção de cor do personagem

ArrayList<Enemy> enemies; // Lista de inimigos (roxos)

color playerColor; // Cor do jogador

void settings() {
  size(771, 548);
}

void setup() {
  resetGame();
  
  backgroundImage = loadImage("sala de aula.png");
  playerImage = loadImage("aluno 1.png");
   playerImage1 = loadImage("aluno4.1.png");
    playerImage2 = loadImage("Run1.png");
   targetImage = loadImage("livro.png");
  enemyImage = loadImage("professor1.png");
  
    // Inicializa a biblioteca Minim
  minim = new Minim(this);
  
  // Carrega os arquivos de áudio
  backgroundMusic = minim.loadFile("trilha.mp3");
  pointSound = minim.loadSample("pontos.wav");
  gameOverSound = minim.loadSample("colidiu.mp3");
  
  // Define as configurações do som
backgroundMusic.setGain(0.5);
pointSound.setGain(0.5);
gameOverSound.setGain(0.5);

}



void draw() {
  background(backgroundImage);

  if (gameStarted) {
    if (!gameOver) {
      movePlayer();
      moveEnemies();
      checkCollision();
      checkWin();
      checkGameOver();
    }

    drawPlayer();
    drawTarget();
    drawEnemies();
    drawScore();
    
  } else {
    if (showCredits) {
      drawCreditsScreen();
    } else if (chooseColor) {
      drawColorSelectionScreen();
    } else if (showHistoria) {
      drawHistoriaScreen();
    } else {
      drawStartScreen();
    }
  }
}

void movePlayer() {
  if (keyPressed && keyCode == UP && playerY > 0) {
    playerY -= playerSpeed;
  } else if (keyPressed && keyCode == DOWN && playerY < height - playerSize) {
    playerY += playerSpeed;
  }
   // Atualiza o índice do sprite atual a cada 5 quadros renderizados
  if (frameCount % 5 == 0) {
    playerImageIndex = (playerImageIndex % 8) + 1;
  }
  
  frameCount++; // Incrementa o contador de quadros
}


void moveEnemies() {
  for (Enemy enemy : enemies) {
    enemy.x -= enemy.speed;

    if (enemy.x < -enemySize) {
      enemy.x = width;
      enemy.speed += enemyAcceleration; // Aumenta a velocidade do inimigo
    }
  }
}

void checkCollision() { 
boolean collided = false; // Variável para indicar se ocorreu uma colisão

  for (Enemy enemy : enemies) {
    float playerCenterX = playerX + playerSize / 2;
    float playerCenterY = playerY + playerSize / 2;
    float enemyCenterX = enemy.x + enemySize / 2;
    float enemyCenterY = enemy.y + enemySize / 2;
    
    // Verifica se a distância entre os centros dos objetos é menor que a soma dos raios
    float distance = dist(playerCenterX, playerCenterY, enemyCenterX, enemyCenterY);
    if (distance < (playerSize / 2 + enemySize / 2) - 20) {
      // O jogador colidiu com um inimigo (roxo)
      score -= 1;
      resetPlayer();
      collided = true; // Indica que ocorreu uma colisão
      break; // Sai do loop ao ocorrer a colisão
    }
  }
  
  if (!collided && playerX + playerSize >= targetX && playerX <= targetX + targetSize && playerY + playerSize >= targetY && playerY <= targetY + targetSize) {
    // O jogador chegou ao final da tela (ganhou um ponto)
    score += 1;
    resetPlayer();
    playPointSound(); // Reproduz o som de ponto
  }
}

void checkWin() {
  if (playerX + playerSize >= targetX && playerX <= targetX + targetSize && playerY + playerSize >= targetY && playerY <= targetY + targetSize) {
    // O jogador chegou ao final da tela (ganhou um ponto)
    score += 1;
    resetPlayer();
    playPointSound(); // Reproduz o som de ponto
    return; // Sai da função assim que ocorrer a chegada ao final da tela
  }
}
void checkGameOver() {
  if (score <= -1) {
    // O jogador atingiu -1 pontos (perdeu o jogo)
    gameOver = true;
    playGameOverSound(); // Reproduz o som de game over
  }
}


void resetGame() {
  score = 0;
  playerSize = 60;
  playerX = width / 2 - playerSize / 2;
  playerY = height - playerSize;
  targetSize = 60;
  targetX = width / 2 - targetSize / 2;
  targetY = 0;
  enemySize = 55;
  playerSpeed = 5;
  enemySpeed = 2;
  gameOver = false;
  gameStarted = false;
  showCredits = false;
  chooseColor = false;

  enemies = new ArrayList<Enemy>();
  addEnemies();

  playerColor = color(0, 255, 0); // Verde (cor padrão)
}

void resetPlayer() {
  playerX = width / 2 - playerSize / 2;
  playerY = height - playerSize;
}

void addEnemies() {
  int numEnemies = 4;
  float spacing = (float)(height - playerSize - targetSize) / (numEnemies + 1);

  for (int i = 1; i <= numEnemies; i++) {
    float x = width - enemySize;
    float y = spacing * i + playerSize;
    float speed = random(1, 4);

    Enemy enemy = new Enemy(x, y, speed);
    enemies.add(enemy);
  }
}

void drawPlayer() {
  String playerImageName = "Run" + playerImageIndex + ".png";
  PImage playerImageCurrent = loadImage(playerImageName);
   switch (playerImageIndex1) {
    case 0:
      image(playerImage, playerX, playerY, playerSize, playerSize);
      break;
    case 1:
      image(playerImage1, playerX, playerY, playerSize, playerSize);
      break;
    case 2:
      image(playerImageCurrent, playerX, playerY, playerSize, playerSize);
      break;
    // Adicione outros cases para cada imagem do jogador que você queira usar
}
}

void drawTarget() {
  image(targetImage, targetX, targetY, targetSize, targetSize);
}

void drawEnemies() {
 for (Enemy enemy : enemies) {
    image(enemyImage, enemy.x, enemy.y, enemySize, enemySize);
}
}


void playPointSound() {
  pointSound.trigger();
}

void playGameOverSound() {
  gameOverSound.trigger();
}

void stop() {
  // Libera os recursos da biblioteca Minim ao fechar o jogo
  backgroundMusic.close();
  pointSound.close();
  gameOverSound.close();
  minim.stop();
  super.stop();
}



void drawScore() {
  fill(255,20,20);
  textSize(20);
  textAlign(LEFT);
  text("Score: " + score, 150, 50);

  if (gameOver) {
    fill(255,20,20);
    textSize(30);
    textAlign(CENTER);
    text("Game Over!", width / 2, height / 2);
    textSize(20);
    text("Pressione 'R' para reiniciar", width / 2, height / 2 + 40);
  }
}

void drawStartScreen() {
  background(0);
  fill(255,0,0);
  textAlign(CENTER);
  textSize(60);
  text("Race to graduate", width / 2, height / 2 - 80);
  fill(255);
  textSize(20);
  text("Pressione 'S' para começar", width / 2, height / 2);
  text("Pressione 'H' para História", width / 2, height / 2 + 50);
  text("Pressione 'C' para créditos", width / 2, height / 2 + 100);
  text("Pressione 'D' para escolher personagem", width / 2, height / 2 + 150);
 
}

void drawCreditsScreen() {
  background(255);
  fill(0);
  textAlign(CENTER);
  textSize(30);
  text("Créditos", width / 2, height / 2 - 100);
  textSize(20);
  text("Desenvolvido por:\n Delian Brajão - RA:202216584\n Alisson Musiau – RA:001202006834\n Bruno Hideaki Olivato – RA:001201804449\n Giovani Santineli Rojas – RA:001202000315\n Mayara Gabriela de Oliveira – RA:001202004753 \n OBRIGADO POR JOGAR !!!\n  ", width / 2, height / 2 - 50);
  text("\n\nPressione 'B' para voltar", width / 2, height / 2 + 100);
}

void drawHistoriaScreen() {
  background(255);
  fill(0);
  textAlign(CENTER);
  textSize(30);
  text("História", width / 2, 25);
  textSize(20);
  text(" Haviam três jovens estudantes empolgados, que eram conhecidos por seu amor\n pelos estudos e sua dedicação aos livros. Um dia, os três receberam uma notícia \n    emocionante: os livros finalmente haviam chegados na biblioteca da escola. Era o\n   último livro que eles precisavam ler para se formar e realizar seu grande sonho de\n se tornarem graduados.", width / 2, height / 2 - 180);
  text("Empolgados com a oportunidade, os estudantes decidiram ir imediatamente à biblioteca\n para pegar o livro. No entanto, eles sabiam que não seria uma tarefa fácil.\n Os professores da escola eram conhecidos por serem rigorosos e sempre de olho nos\n alunos, especialmente durante o horário de aula.", width / 2, height / 2 );
  text("\n\nPressione 'B' para voltar", width / 2, height / 2 + 180);
}

void drawColorSelectionScreen() {
  background(0);
  fill(255,20,20);
  textAlign(CENTER);
  textSize(30);
  text("Escolha o personagem", width / 2, height / 2 - 170);
  textSize(20);
  text("Pressione 'G'               para aluno1", width / 2, height / 2 - 120);
  text("Pressione 'A'               para aluno2", width / 2, height / 2 - 70);
  text("Pressione 'V'               para aluno3", width / 2, height / 2 - 20);
   text("\nEscolha e volte ao início", width / 2, height / 2 + 120);
  text("\nPressione 'B' para voltar", width / 2, height / 2 + 30);

  // Desenha as imagens dos personagens para seleção
  image(playerImage, width / 2 - playerSize / 2+5, height / 2 - playerSize - 110, playerSize, playerSize);
  image(playerImage1, width / 2 - playerSize / 2+2, height / 2 - playerSize / 2 - 80, playerSize, playerSize);
  image(playerImage2, width / 2 - playerSize / 2-10, height / 2 + playerSize / 2 - 120, playerSize+30, playerSize+30);
}



void keyPressed() {
  if (!gameStarted) {
    if (key == 's' || key == 'S') {
      gameStarted = true;
    } else if (key == 'h' || key == 'H') {
      showHistoria = true;  
    } else if (key == 'c' || key == 'C') {
      showCredits = true;
    } else if (key == 'd' || key == 'D') {
      chooseColor = true;
    }
  } else {
    if (gameOver && (key == 'r' || key == 'R')) {
      resetGame();
    }
  }

  if (showCredits && (key == 'b' || key == 'B')) {
    showCredits = false;
  }
  if (showHistoria && (key == 'b' || key == 'B')) {
    showHistoria = false;
  }

 if (chooseColor) {
  if (key == 'g' || key == 'G') {
    playerColor = color(0, 255, 0);
    playerImageIndex1 = 0;
    chooseColor = false;
  } else if (key == 'a' || key == 'A') {
    playerColor = color(0, 0, 255);
    playerImageIndex1 = 1;
    chooseColor = false;
  } else if (key == 'v' || key == 'V') {
    playerColor = color(255, 0, 0);
    playerImageIndex1 = 2;
    chooseColor = false;
  } else if (key == 'b' || key == 'B') {
    chooseColor = false;
    }
  }
}

class Enemy {
  float x, y; // Posição do inimigo
  float speed; // Velocidade de movimento do inimigo

  Enemy(float x, float y, float speed) {
    this.x = x;
    this.y = y;
    this.speed = speed;
  }
}
