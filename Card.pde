class Card{
  int iconCnt = 5; // Spade, Heart, ClubとDiamond
  int numCnt = 14; // Ace, 2~10, Jack, Queen, King
  int x, y, wrongMatchPosX, wrongMatchPosY, num_opened_cards;
  int tempX, tempY; //選んだ一枚目カードの位置を保存する
  //カードは配列で表示する
  String[][] card_value;  // カードの値(内容)
  int[][] show_card_flag; // カードを表示するフラグ
  int[][] opened_card;    // 一致するカード
  boolean savedFirstChosenCard; //一枚目カードの位置を保存するフラグ
  
  Card(int x, int y){
    this.x = x;
    this.y = y;
    card_value = new String[x][y];
    show_card_flag = new int[x][y];
    opened_card = new int[x][y];
    savedFirstChosenCard = false;
    CardInit();
  }
  
  //カードを初期化する
  void CardInit() {
    for(int i = 0; i < x; i++) {
      for(int j = 0; j < y; j++){
        card_value[i][j] = "";
        show_card_flag[i][j] = 0;
        opened_card[i][j] = 0;
      }
    }
  }
  
  //タイトル画面
  void PrintTitle(String Card1, String Card2){
    
    fill(255, 255, 0);
    textSize(64);
    text("神経衰弱!!", 280, 300);
    textSize(48);
    text("Press Enter key to start game", 120, 750);

    PImage img = loadImage(Card1+".jpg");
    image(img, 170, 450, 100, 152);
      
    PImage img2 = loadImage("Gray_back.jpg"); 
    image(img2, 320, 450, 100, 152);
    
    PImage img3 = loadImage(Card2+".jpg");
    image(img3, 470, 450, 100, 152);
      
    PImage img4 = loadImage("Gray_back.jpg"); 
    image(img4, 620, 450, 100, 152);
  }
  
  // カードが合わせない時、二枚目カードをのX位置を設置する
  void SetWrongMatchPosX(int posX){
    wrongMatchPosX = posX;
  }
  
  // カードが合わせない時、二枚目カードをのY位置を設置する
  void SetWrongMatchPosY(int posY){
    wrongMatchPosY = posY;
  }
  
  int GetWrongMatchPosX(){
    return wrongMatchPosX;
  }
  
  int GetWrongMatchPosY(){
    return wrongMatchPosY;
  }
  
  // 一枚目カードが保存されるフラグ
  boolean CheckSavedFirstChosenCard(){
    return savedFirstChosenCard;
  }
  
  // ランダムパターン配列を初期化する
  String[] randomPatternInit(String[] randomPattern, int patternNum){
    randomPattern = new String[patternNum];
    for(int i = 0; i < patternNum; i++){
      randomPattern[i] = "";
    }
    return randomPattern;
  }
  
  // ランダムパターン
  String[] RandomPattern(String[] randomPatternStr, int patternNum){
    int randomedPatternIndex = 0;
    while(randomedPatternIndex < patternNum){
      boolean canAdd = true;
      String ranIcon = card.RandomIcon(iconCnt);
      String ranNum = card.RandomNum(numCnt);
      String cardValue = ranNum+ranIcon;
      for(String s : randomPatternStr){
        if(s.equals(cardValue)){
          canAdd = false;
        }
      }
      if(canAdd){
        randomPatternStr[randomedPatternIndex] = cardValue;
        randomedPatternIndex++;
      }
    }
    return randomPatternStr;
  }

  // ランダムスート
  String RandomIcon(int icon){
    int ranIcon = int(random(1, icon));
    String strRanIcon;
    //ファーストアルファベットで設定する
    switch(ranIcon){
      case 1:
        strRanIcon = "S";
        break;
      case 2:
        strRanIcon = "H";
        break;
      case 3:
        strRanIcon = "C";
        break;
      case 4:
        strRanIcon = "D";
        break;
      default:
        strRanIcon = "S";
        break;
    }
    return strRanIcon;
  }
  
  // ランダム数字
  String RandomNum(int num){
    int ranNum = int(random(1, num));
    String strRanNum;
    // 1、11～13は数字ではなくアルファベットで設定する
    switch(ranNum){
      case 1:
        strRanNum = "A";
        break;
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
        strRanNum = str(ranNum);
        break;
      case 11:
        strRanNum = "J";
        break;
      case 12:
        strRanNum = "Q";
        break;
      case 13:
        strRanNum = "K";
        break;
      default:
        strRanNum = "J";
        break;
    }
    return strRanNum;
  }
  
  
  String RandomCard(){
    String ranIcon = RandomIcon(iconCnt);  // Spade, Heart, ClubとDiamond
    String ranNum = RandomNum(numCnt);   // AceからKingまで
    String cardValue = ranNum+ranIcon;
  
    return cardValue;
  }
  
  void ShuffleCard(int numCards, String[]randomPatternStr){
    int randomPatternNum = numCards / 2;
    // ランダムするカードの値を初期化する
    randomPatternStr = randomPatternInit(randomPatternStr, randomPatternNum);
    // 配置するカードの値を初期化する
    CardInit();
  
    int randomedCard = 0;
    // 先に10枚カードをランダムで決定する
    randomPatternStr = RandomPattern(randomPatternStr, randomPatternNum);
    // ランダムされたカードを配置する
    AssignCard(randomedCard, numCards, randomPatternStr);
    // ディベロッパー用
    printCardInArray();
  }
  
  // ランダムしたカードを"card_value"にアサインする
  void AssignCard(int randomedCard, int numCards, String[] randomPatternStr){
    int index = 0;
    while(randomedCard < numCards){
      int tempX1 = int(random(0, x));
      int tempY1 = int(random(0, y));
      int tempX2 = int(random(0, x));
      int tempY2 = int(random(0, y));
      // カードの内容は"x,y"として保存する
      String tempXY1 = str(tempX1)+","+str(tempY1);
      String tempXY2 = str(tempX2)+","+str(tempY2);
      
      if(!tempXY1.equals(tempXY2) &&  // 一枚目の位置と二枚目の位置が一致していない場合
         CardValueNotExist(tempX1, tempY1) && 
         CardValueNotExist(tempX2, tempY2)){
           SetCardValue(tempX1, tempY1, randomPatternStr[index]);
           SetCardValue(tempX2, tempY2, randomPatternStr[index]);
           randomedCard+=2;
           index++;
      }
    }
  }

  void SetCardValue(int x, int y, String cardValue){
    card_value[x][y] = cardValue;
  }
  
  String GetCardValue(int x, int y){
    return card_value[x][y];
  }
  
  // 設定するカードの位置は、既にカードが存在するかどうかを確認する
  boolean CardValueNotExist(int x, int y){
    if(card_value[x][y] == ""){
      return true;
    } else {
      return false;
    }
  }
  
  // マウスをクリックする時、その座標はカードの範囲以内にあるかどうかチェックする
  boolean CheckClickedMousePosition(int mouse_X, int mouse_Y, int i, int j){
    if((mouse_X >= 100 + 150 * i) && (mouse_X <= 100 + 150 * i + 100) &&
       (mouse_Y >= 100 + 200 * j) && (mouse_Y <= 100 + 200 * j + 152)){
      return true;
    } else {
      return false;
    }
  }
  
  void DrawCard(){
    for(int i = 0; i < x; i++){
      for(int j = 0; j < y; j++) {
        if(show_card_flag[i][j] == 0){
          PImage img = loadImage("Gray_back.jpg");  // カードの値(内容)を表示しない
          image(img, 100 + 150 * i, 100 + 200 * j, 100, 152);
        } else {
          PImage img = loadImage(card_value[i][j]+".jpg");
          image(img, 100 + 150 * i, 100 + 200 * j, 100, 152);
        }
      }
    }
  }
  
  // カードを表示する
  void ShowCard(int x, int y){
    show_card_flag[x][y] = 1;
  }
  
  // 選んだ2枚カードが一致すれば、"合わせる状態"を保存する
  void setCardOpened(int posX, int poxY) {
    opened_card[posX][poxY] = 1;
    opened_card[tempX][tempY] = 1;
  }
  
  // カードを隠す
  void HideCard(int x, int y){
    show_card_flag[x][y] = 0;
    show_card_flag[tempX][tempY] = 0;
    savedFirstChosenCard = false;
  }
  
  // 同じカードを選択するかどうかチェックする
  boolean CheckRepeatChoose(int x, int y){
    if(tempX == x && tempY == y){
      return true;
    } else {
      return false;
    }
  }
  
  // 既に合わせるカードを確認する
  boolean CheckChosenShownCard(int x, int y){
    if(opened_card[x][y] == 1){
      return true;
    } else {
      return false;
    }
  }
  
  // 選んだ1枚目カードの座標を保存する
  void SaveChosenFirstCard(int x, int y){
    tempX = x;
    tempY = y;
    savedFirstChosenCard = true;
  }
  
  // カード内容を比較する
  boolean MatchCard(int x, int y){
    if(card_value[tempX][tempY] == card_value[x][y]){
      num_opened_cards+=2;
      savedFirstChosenCard = false;
      return true;
    }
    else {
      return false;
    }
  }
  
  int AddScore(int score){
    score += 10;
    return score;
  }
  
  // 全部カードを開いている状態なら、カードをシャッフルする
  boolean CheckAllOpen() {
    if(num_opened_cards >= x * y){
      num_opened_cards = 0;
      return true;
    } else {
      return false;
    }
  }
  
  void DrawScore(int score){
    String strScore = str(score);
    if(score < 100){
      strScore = " "+strScore;
    }
    noStroke();
    fill(0, 204, 0);
    rect(50, 50 - 32, textWidth("Player Score: "+score), 33);
    textSize(32);
    fill(255, 255, 0);
    text("Player Score: "+score, 50, 50);
  }
  
  void DrawTimer(int time_left){
    String strTimeLeft = str(time_left);
    if(time_left < 10){
      strTimeLeft = "  "+str(time_left);
    }
    noStroke();
    fill(0, 204, 0);
    rect(350, 50 - 32, textWidth("Time Left: "+strTimeLeft), 33);
    textSize(32);
    fill(255, 255, 0);
    text("Time Left: "+strTimeLeft, 350, 50);
  }
  
  // 以下のメソッドはディベロッパー用
  void printCard(){
    for(int i=0; i<x; i++){
      for(int j=0; j<y; j++){
        println("i: "+i+", j: "+j+", card value: "+card_value[i][j]);
      }
    }
  }
  
  void printCardInArray(){
    for(int i=0; i<y; i++){
      for(int j=0; j<x; j++){
        print(card_value[j][i]+" ");
      }
      println("");
    }
    println("");
  }
  
  void printShowCardStatusInArray(){
    for(int i=0; i<y; i++){
      for(int j=0; j<x; j++){
        print(show_card_flag[j][i]+" ");
      }
      println("");
    }
    println("");
  }
  
  void printOpenedCardStatusInArray(){
    for(int i=0; i<y; i++){
      for(int j=0; j<x; j++){
        print(opened_card[j][i]+" ");
      }
      println("");
    }
    println("");
  }
  
  void printRandomPattern(String[] randomPattern){
    println("Pattern: ");
    for(String s : randomPattern){
      println(s);
    }
    println("");
  }
  
  void PrintChosenFirstCard(){
    println("TempX: "+tempX+", TempY: "+tempY);
  }
}
