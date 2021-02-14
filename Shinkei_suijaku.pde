/*
作成日: 2018-07-28
学籍番号: A18DC593
名前: 楊家祺(ヨウカキ)
タイトル: 神経衰弱!!
ゲーム内容: プレイヤーにショート記憶を訓練させます
ゲームの流れ:
1. カードを5 x 4として配置する
2. カードをシャッフルしてスタートする (カードはポーカーカード)
3. プレイヤーがカードを2枚選択する
合わせる場合はスコア+10, 選んだ2枚カードはそのまま表示する
合わせない場合は、選んだ2枚カードが隠される
全部カードが開いたら、再びカードをシャッフルする
4. 時間が終わったら、ゲームオーバーでプレイヤースコアを表示する
5. プレイヤーに再挑戦する事を確認する
改善点:
1. マウス左クリックの敏感度が高くない
2. 今CardクラスのHideCard()はマウスを移動してからコールする事が必要です。
出来ればマウスを移動しなくても自動的に隠れた方がいいと思います。
ただしdelay()を使えば、2枚目カードが1枚目に合わせない時直接的に隠れます(つまり2枚目の内容が表示されません)
注意: 
1. 画像は、ProcessingでCMYKモードが読みないのでRGBモードへ変換する事が必要です。
2. BGMがあります
*/

// "スケッチ" -> "ライブラリをインポート" -> "Minim"を検索する -> インストール
import ddf.minim.*;

PFont font;
int timer = 91, defaultTimer = timer, remainingTime;
int score = 0, x = 5, y = 4, secs = 0, elapsedTime = 0;
int iconCnt = 5; // Spade, Heart, ClubとDiamond
int numCnt = 14; // Ace, 2~10, Jack, Queen, King
int pair = 2, ranPair, numCards, showedCard = 0, mode = 1;
String[] randomPatternStr;
boolean gameStart = false, gameOver = false, matchFlag = true;
String chooseCardSEFile = "se_maoudamashii_system38.mp3";
String wrongMatchSEFile = "se_maoudamashii_onepoint33.mp3";
String rightMatchSEFile = "se_maoudamashii_onepoint23.mp3";
String gameBGMFile = "game_maoudamashii_1_battle33.mp3";
String randomCard1, randomCard2;
Minim chooseCardSE, wrongMatchSE, rightMatchSE, gameBGM;
AudioPlayer chooseCardSEAP, wrongMatchSEAP, rightMatchSEAP, gameBGMAP;
Card card;

void setup(){
  frameRate(60);
  size(900, 900);
  background(0, 204, 0);
  card = new Card(x, y); // カードは画面上にグリッドの形式で表示する
  numCards = x * y;
  card.ShuffleCard(numCards, randomPatternStr); //カードをシャッフルする
  
  chooseCardSE = new Minim(this);
  wrongMatchSE = new Minim(this);
  rightMatchSE = new Minim(this);
  gameBGM = new Minim(this);
  chooseCardSEAP = chooseCardSE.loadFile(chooseCardSEFile);  // カードを選択するSE
  wrongMatchSEAP = wrongMatchSE.loadFile(wrongMatchSEFile);  // カードが一致しない場合のSE
  rightMatchSEAP = rightMatchSE.loadFile(rightMatchSEFile);  // カードが一致する場合のSE
  gameBGMAP = gameBGM.loadFile(gameBGMFile); // ゲームのBGM
  //SE音量を大きくする
  chooseCardSEAP.setGain(5);
  wrongMatchSEAP.setGain(5);
  rightMatchSEAP.setGain(5);
  gameBGMAP.setGain(-20); //BGM音量を小さくする
  
  // 下記のカードはタイトル画面用
  randomCard1 = card.RandomCard();
  randomCard2 = card.RandomCard();
  
  //日本語を表示する
  font = createFont("ＭＳ Ｐ明朝B", 64);
  textFont(font);
}

void draw(){
  if(!gameStart){ // ゲームは未スタート状態
    // タイトル画面を表示する
    card.PrintTitle(randomCard1, randomCard2);
    // 毎秒カードを変えます
    if(int(millis()/1000) != secs){
      randomCard1 = card.RandomCard();
      randomCard2 = card.RandomCard();
      secs = int(millis()/1000);
    }
  }
  else if(!gameOver){ // ゲームはスタート状態
  
    // ゲームBGMをループする
    if(!gameBGMAP.isPlaying()){
      gameBGMAP.play(0);
    }
    
    if(mousePressed){
      
      // マウス座標をグリッド位置に変換する
      int posX = (mouseX - 100) / 150;
      // カートの上の範囲による計算されたＹ位置の値は、下の範囲による計算されたＹ位置1を引く
      // なので上の範囲または下の範囲をクリックしてもposYが同じ値です
      int posY = ((mouseY - 152) % 200) >= 100 ? (mouseY - 152) / 200 + 1 : (mouseY - 152) / 200;
      
      // 計算された座標がカードの選択範囲にあるかどうか確認する
      if(!card.CheckClickedMousePosition(mouseX, mouseY, posX, posY)){
        wrongMatchSEAP.play(0);
        return;
      }
      // 配列のインデックスは0からx-1 / y-1です
      else if(posX >=x || posY >= y){
        return;
      } else {
        chooseCardSEAP.play(0);
      }
      
      card.ShowCard(posX, posY);
      
      // 下のSaveChosenFirstCard()に同じ位置が保存される事を防止する
      if(card.CheckRepeatChoose(posX, posY)){
        showedCard = 1;
      } else {
        showedCard++;
      }
     
      if(card.CheckChosenShownCard(posX, posY)){ // 既に合わせるカードは位置を保存しません
        showedCard = 1;
      }
      else if(showedCard % 2 == 0) { // カードを二枚選択したら比較する
        if(card.CheckChosenShownCard(posX, posY)){
          showedCard = 1;
        }else if(card.MatchCard(posX, posY)){ // 合わせる場合
          score = card.AddScore(score);
          rightMatchSEAP.play(0);
          card.setCardOpened(posX, posY);
        } else { // 合わせない場合
          matchFlag = false;
          card.SetWrongMatchPosX(posX);
          card.SetWrongMatchPosY(posY);
          wrongMatchSEAP.play(0);
        }
        showedCard = 0;
      } else {
        // 選択した一枚目カードの位置を保存して、次に二枚目カードを選択したらカードの内容を比較する
        // ただし、既に合わせるカードは位置を保存しません
        if(!card.CheckChosenShownCard(posX, posY)){
          card.SaveChosenFirstCard(posX, posY);
        } else {
          if(card.CheckSavedFirstChosenCard()){
            showedCard = 1;
          } else{
            showedCard = 0;
          }
        }
      }
    }
    
    card.DrawScore(score);
    card.DrawCard();
    
    remainingTime = timer + elapsedTime - int(millis() / 1000); // 時間を1秒ずつ流す
    card.DrawTimer(remainingTime);
    if(remainingTime <= 0){
      gameOver = true;
    }
    
    // 全部カードが表示されたらカードをシャッフルする
    if(card.CheckAllOpen()){
      card.ShuffleCard(numCards, randomPatternStr);
    }
  }
  else {
    // ゲームオーバー
    gameBGMAP.pause();
    GameOver();
    if(keyPressed){
      if(key == ENTER){ 
        RestartGame(); // ゲームをやり直す
      }
    }
  }
}

// マウスを移動したら、一致しないカードを隠す
void mouseMoved(){
  if(matchFlag == false){
    delay(20);
    int posX = card.GetWrongMatchPosX();
    int posY = card.GetWrongMatchPosY();
    card.HideCard(posX, posY);
    matchFlag = true;
  }
}

void mouseDragged(){
  println("Showed Card: "+showedCard);
}

// 入力したキーを処理する
void keyPressed()
{
  if ( key == ENTER )
  {
    if(gameStart == false){
      gameStart = true;
      background(0, 204, 0); // タイトル画面をクリアする
      gameBGMAP.play(0);
      timer = defaultTimer;
      // millis()はゲームがスタートする前にずっと動いているので、
      // Enterキーを押したら、何秒が流れたのを保存する
      elapsedTime = int(millis() / 1000);
    }
  }
}

// ゲームオーバー
void GameOver(){
  background(0, 204, 0);
  fill(255, 255, 0);
  textSize(64);
  text("Game Over!", 250, 300);
  text("Your Score: "+score, 250, 500);
  text("Press Enter key to restart", 100, 700);
}

// ゲームをリスタートする
void RestartGame(){
  gameOver = false;
  score = 0;
  timer = defaultTimer;
  elapsedTime = int(millis() / 1000); // keyPressed()中のelapsedTimeと同じ理由
        
  background(0, 204, 0); // ゲーム画面をクリアする
  card.ShuffleCard(numCards, randomPatternStr);
  gameBGMAP.play(0);
}

// プログラムを停止する
void stop()
{
  // 全部Audio Playerをクローズする
  gameBGMAP.close();
  chooseCardSEAP.close();
  rightMatchSEAP.close();
  wrongMatchSEAP.close();
  super.stop();
}
