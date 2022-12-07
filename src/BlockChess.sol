// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

    contract Spot {
        uint private x;
        uint private y;
        Piece private piece;
        bool private isEmpty;

        constructor( uint _x, uint _y, Piece _piece){
            x = _x;
            y = _y;
            piece = _piece;
        }

        function getPiece() public view returns(Piece){
            return piece;
        }

        function setPiece(Piece _piece) public {
            piece = _piece;
        }

        function getX() public view returns(uint){
            return x;
        }

        function setX(uint _x) public {
            x = _x;
        }

        function getY() public view returns(uint){
            return y;
        }

        function setY(uint _y) public {
            y = _y;
        }
    }

    contract Board {
        Spot[8][8] boxes;

        constructor(){
            resetBoard();
        }

        function getBox(uint x, uint y) public view returns(Spot){
            require(x > 0 && x < 7 && y > 0 && y < 7, "outOfBounds");

            if(x < 0 || x > 7 || y < 0 || y > 7){
                revert("outOfBounds");
            }

            return boxes[x][y];
        }

        function resetBoard() public {
            //White Pieces
            boxes[0][0] = new Spot(0,0, new Rook(PieceStatus.WHITE));
            boxes[0][1] = new Spot(0,1, new Bishop(PieceStatus.WHITE));
            boxes[0][2] = new Spot(0,2, new Knight(PieceStatus.WHITE));
            boxes[0][3] = new Spot(0,3, new King(PieceStatus.WHITE));
            boxes[0][4] = new Spot(0,4, new Queen(PieceStatus.WHITE));
            boxes[0][5] = new Spot(0,5, new Knight(PieceStatus.WHITE));
            boxes[0][6] = new Spot(0,6, new Bishop(PieceStatus.WHITE));
            boxes[0][7] = new Spot(0,7, new Rook(PieceStatus.WHITE));

            //White Pawns
            for(uint i = 0; i < 8; i++){
                boxes[1][i] = new Spot(1,i, new Pawn(PieceStatus.WHITE));
            }

            //Black Pieces
            boxes[7][0] = new Spot(0,0, new Rook(PieceStatus.BLACK));
            boxes[7][1] = new Spot(0,1, new Bishop(PieceStatus.BLACK));
            boxes[7][2] = new Spot(0,2, new Knight(PieceStatus.BLACK));
            boxes[7][3] = new Spot(0,3, new King(PieceStatus.BLACK));
            boxes[7][4] = new Spot(0,4, new Queen(PieceStatus.BLACK));
            boxes[7][5] = new Spot(0,5, new Knight(PieceStatus.BLACK));
            boxes[7][6] = new Spot(0,6, new Bishop(PieceStatus.BLACK));
            boxes[7][7] = new Spot(0,7, new Rook(PieceStatus.BLACK));

            //Black Pawns
            for(uint i = 0; i < 8; i++){
                boxes[6][i] = new Spot(1,i, new Pawn(PieceStatus.BLACK));
            }

            //empty squares
            for(uint i = 2; i < 6; i++){
                for(uint j = 0; j < 7; j++){
                    boxes[i][j] = new Spot(i,j, new Empty(PieceStatus.EMPTY));
                }
            }
        }
    }
     enum PieceStatus{
        WHITE,
        BLACK,
        EMPTY
    }

    contract Piece {
        bool private captured;
        PieceStatus public pieceStatus;

       constructor(PieceStatus _status) {
            pieceStatus = _status;
       }

       function peiceStatus() public view returns(PieceStatus) {
            return pieceStatus;
       }

       function setColor(PieceStatus _status) public {
            pieceStatus = _status;
       }

       function isCaptured() public view returns(bool) {
            return captured;
       }

       function setCaptured(bool _captured) public{ 
            captured = _captured;
       }

        function canMove(Board _board, Spot start, Spot end) external virtual returns(bool){
        }
    }

    contract Empty is Piece{

        constructor(PieceStatus _status) Piece(_status){
       }

        function canMove(Board board, Spot start, Spot end) external pure override(Piece) returns(bool){
            return false;
        }
    }

    contract King is Piece { //untested
        bool castled = false;

       constructor(PieceStatus _status) Piece(_status){
       }

        function isCastled() public view returns(bool){
            return castled;
        }

        function setCastled(bool _castled) public{
            castled = _castled;
        }

        function canMove(Board board, Spot start, Spot end) external view override(Piece) returns(bool){
            //cannot move to a square occupied by a same color piece
            if(end.getPiece().pieceStatus() == this.pieceStatus()){
                return false;
            }

            uint x;
            uint y;

            if(start.getX() > end.getX()){
                x = (start.getX() - end.getX());
            }else{
                x = (end.getX() - start.getX());
            }
            
            if(start.getY() > end.getY()){
                y = (start.getY() - end.getY());
            }else{
                y = (end.getY() - start.getY());
            }
            
            
            if((x == 1 && y == 0) ||
            (x == 0 && y == 1) || //adjacent moves
            (x == 1 && y == 1)){ // diagonal moves
                return true;
            }
            
            return true;
            //return this.isCastlingValid(board, start, end);
        }

    //    function isCastlingValid(Board board, Spot start, Spot end) public returns(bool){
    //         if(this.isCastlingDone){
    //             return false;
    //         }
    //     }
        //need to implement valid castling checks
    }

    contract Rook is Piece{ //untested

        constructor(PieceStatus _status) Piece(_status){
       }

        function canMove(Board board, Spot start, Spot end) external view override(Piece) returns(bool){
            //cannot move to a square occupied by a same color piece
            if(end.getPiece().pieceStatus() == this.pieceStatus()){
                return false;
            }

            uint x;
            uint y;

            if(start.getX() > end.getX()){
                x = (start.getX() - end.getX());
                for(uint i = end.getX(); i <= x; i++){
                    if(board.getBox(i,start.getY()).getPiece().pieceStatus() != PieceStatus.EMPTY){
                        return false;
                    }
                }
            }else if(start.getX() < end.getX()){
                x = (end.getX() - start.getX());
                for(uint i = start.getX(); i <= x; i++){
                    if(board.getBox(i,start.getY()).getPiece().pieceStatus() != PieceStatus.EMPTY){
                        return false;
                    }
                }
            }
            
            if(start.getY() > end.getY()){
                y = (start.getY() - end.getY());
                for(uint i = end.getY(); i <= y; i++){
                    if(board.getBox(start.getX(),i).getPiece().pieceStatus() != PieceStatus.EMPTY){
                        return false;
                    }
                }
            }else if(start.getY() < end.getY()){
                y = (end.getY() - start.getY());
                for(uint i = start.getY(); i <= y; i++){
                    if(board.getBox(start.getX(),i).getPiece().pieceStatus() != PieceStatus.EMPTY){
                        return false;
                    }
                }
            }

            if((x < 7  && y == 0) ||
            (x == 0 && y < 7 )){}
                return true;
            }
        }

    contract Queen is Piece{ //untested

        constructor(PieceStatus _status) Piece(_status){
       }

        function canMove(Board board, Spot start, Spot end) external view override(Piece) returns(bool){
            //cannot move to a square occupied by a same color piece
            if(end.getPiece().pieceStatus() == this.pieceStatus()){
                return false;
            }

            uint x;
            uint y;

            if(start.getX() > end.getX()){
                x = (start.getX() - end.getX());
                    if(start.getY() > end.getY()){ //back x back y
                        y = (start.getY() - end.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //diagonal check
                            return false;
                                for(uint i = 1; i < x; i++){ //collision check
                                    uint xi = end.getX() + i;
                                    uint yi= end.getY() + i;
                                    if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                        return false;
                                    }
                                }
                        }else if((end.getX() > 7 || end.getY() > 7 || end.getX() < 0 || end.getY() < 0) || //valid bounds check
                                    ((x > 0 && y > 0)) || (x == 0 && y == 0)){ //actual move and orthogonal check
                            return false;
                                if(y == 0){
                                    for(uint i = 1; i < x; i++){ //collision check
                                        uint xi = end.getX() + i;
                                        if(board.getBox(xi,start.getY()).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }
                                    }
                                }else if(x == 0){
                                    for(uint i = 1; i <y; i++){ //collision check
                                        uint yi = end.getY() + i;
                                        if(board.getBox(start.getX(),yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }  
                                    }
                                }
                        }
                    }else if(start.getY() < end.getY()){ // back x forward y
                        y = (start.getY() - end.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //diagonal check
                            return false;
                                for(uint i = 1; i < x; i++){ //collision check
                                    uint xi = end.getX() + i;
                                    uint yi= start.getY() + i;
                                    if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                        return false;
                                    }
                                }
                        }else if((end.getX() > 7 || end.getY() > 7 || end.getX() < 0 || end.getY() < 0) || //valid bounds check
                                    ((x > 0 && y > 0)) || (x == 0 && y == 0)){ //actual move and orthogonal check
                            return false;
                                if(y == 0){
                                    for(uint i = 1; i < x; i++){ //collision check
                                        uint xi = end.getX() + i;
                                        if(board.getBox(xi,start.getY()).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }
                                    }
                                }else if(x == 0){
                                    for(uint i = 1; i < y; i++){ //collision check
                                        uint yi = start.getY() + i;
                                        if(board.getBox(start.getX(),yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }  
                                    }
                                }
                        }
                    }

            } else if(start.getX() < end.getX()){
                x = (end.getX() - start.getX());
                    if(start.getY() > end.getY()){ //forward x back y
                        y = (start.getY() - end.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //diagonal check
                            return false;
                                for(uint i = 1; i < x; i++){ //collision check
                                    uint xi = start.getX() + i;
                                    uint yi= end.getY() + i;
                                    if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                        return false;
                                    }
                                }
                        }else if((end.getX() > 7 || end.getY() > 7 || end.getX() < 0 || end.getY() < 0) || //valid bounds check
                                    ((x > 0 && y > 0)) || (x == 0 && y == 0)){ //actual move and orthogonal check
                            return false;
                                if(y == 0){
                                    for(uint i = 1; i < x; i++){ //collision check
                                        uint xi = start.getX() + i;
                                        if(board.getBox(xi,start.getY()).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }
                                    }
                                }else if(x == 0){
                                    for(uint i = 1; i < y; i++){ //collision check
                                        uint yi = end.getY() + i;
                                        if(board.getBox(start.getX(),yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }  
                                    }
                                }
                        }
                    }else if(start.getY() < end.getY()){ //forward x forward y
                        y = (end.getY() - start.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //diagonal check
                            return false;
                                for(uint i = 1; i < x; i++){
                                    uint xi = start.getX() + i;
                                    uint yi= start.getY() + i;
                                    if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                        return false;
                                    }
                                }
                        }else if((end.getX() > 7 || end.getY() > 7 || end.getX() < 0 || end.getY() < 0) || //valid bounds check
                                    ((x > 0 && y > 0)) || (x == 0 && y == 0)){ //actual move and orthogonal check
                            return false;
                                if(y == 0){
                                    for(uint i = 1; i < x; i++){ //collision check
                                        uint xi = start.getX() + i;
                                        if(board.getBox(xi,start.getY()).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }
                                    }
                                }else if(x == 0){
                                    for(uint i = 1; i < y; i++){ //collision check
                                        uint yi = start.getY() + i;
                                        if(board.getBox(start.getX(),yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                            return false;
                                        }  
                                    }
                                }
                        }
                    }
            }
            return true;
        }
    }

    contract Knight is Piece{ //untested

        constructor(PieceStatus _status) Piece(_status){
       }

        function canMove(Board board, Spot start, Spot end) external override(Piece) returns(bool){
            //cannot move to a square occupied by a same color piece
            if(end.getPiece().pieceStatus() == this.pieceStatus()){
                return false;
            }

            uint x;
            uint y;

            if(start.getX() > end.getX()){
                x = (start.getX() - end.getX());
            }else{
                x = (end.getX() - start.getX());
            }
            
            if(start.getY() > end.getY()){
                y = (start.getY() - end.getY());
            }else{
                y = (end.getY() - start.getY());
            }
            
            
            if((x == 2 && y == 1) ||
                (x == 1 && y ==2)){
                    return true;
            }
        }
    }

    contract Bishop is Piece{ //broken

       constructor(PieceStatus _status) Piece(_status){
       }

        function canMove(Board board, Spot start, Spot end) external override(Piece) returns(bool){
            //cannot move to a square occupied by a same color piece
            if(end.getPiece().pieceStatus() == this.pieceStatus()){
                return false;
            }

            uint x;
            uint y;

            if(start.getX() > end.getX()){
                x = (start.getX() - end.getX());
                    if(start.getY() > end.getY()){ //back x back y
                        y = (start.getY() - end.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //check for valid bounds and diagonal
                            return false;
                        } else{
                            for(uint i = 1; i < x; i++){
                                uint xi = end.getX() + i;
                                uint yi= end.getY() + i;
                                if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                    return false;
                                }
                            }
                        }
                    }
                    
                    else if(start.getY() < end.getY()){ // back x forward y
                        y = (end.getY() - start.getY());
                        if( end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //check for valid bounds and diagonal
                            return false;
                        }else{
                            for(uint i = 1; i < x; i++){
                                uint xi = end.getX() + i;
                                uint yi= start.getY() + i;
                                if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                    return false;
                                }
                            }
                        }
                    }
            } else if(start.getX() < end.getX()){
                x = (end.getX() - start.getX());
                    if(start.getY() > end.getY()){ //forward x back y
                        y = (start.getY() - end.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //check for valid bounds and diagonal
                            return false;
                        } else{
                            for(uint i = 1; i < x; i++){
                                uint xi = start.getX() + i;
                                uint yi= end.getY() + i;
                                if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                    return false;
                                }
                            }
                        }
                    }
                    
                    else if(start.getY() < end.getY()){ //forward x forward y
                        y = (end.getY() - start.getY());
                        if(end.getX() > 7 || end.getY() > 7 || x != y || end.getX() < 0 || end.getY() < 0){ //check for valid bounds and diagonal
                            return false;
                        } else{
                            for(uint i = 1; i < x; i++){
                                uint xi = start.getX() + i;
                                uint yi= start.getY() + i;
                                if(board.getBox(xi,yi).getPiece().pieceStatus() != PieceStatus.EMPTY){
                                    return false;
                                }
                            }
                        }
                    }
            }
        }
    }

    contract Pawn is Piece{ //needs en passent

        constructor(PieceStatus _status) Piece(_status){
       }

        function canMove(Board board, Spot start, Spot end) external override(Piece) returns(bool){
            //cannot move to a square occupied by a same color piece
            if(end.getPiece().pieceStatus() == this.pieceStatus()){
                return false;
            }

            uint x;
            uint y;

            if(start.getX() > end.getX()){
                x = (start.getX() - end.getX());
            }else{
                x = (end.getX() - start.getX());
            }
            
            if(start.getY() > end.getY()){
                y = (start.getY() - end.getY());
            }else{
                y = (end.getY() - start.getY());
            }
            

            if((start.getY() == 0 && y == 2 && x == 0 && end.getPiece().pieceStatus() == PieceStatus.EMPTY && //double first move
            board.getBox(1,start.getY()).getPiece().pieceStatus() == PieceStatus.EMPTY)){ //check collision
                return true;
            }else if((y == 1 && x == 0) && end.getPiece().pieceStatus() == PieceStatus.EMPTY){
                return true;
            }else if(y == 1 && x == 1 && (end.getPiece().pieceStatus() != (this.pieceStatus())) 
            && end.getPiece().pieceStatus() != PieceStatus.EMPTY){ //check if valid capture
                return true;
            }
        }
    }

    contract Player {
       bool public whiteSide;

        constructor(bool isWhite){
            whiteSide = isWhite;
        }

       function isWhiteSide() public view returns(bool){
            return whiteSide;
       }
    }

    contract Move {
        Player private player;
        Spot private start;
        Spot private end;
        Piece private pieceMoved;
        Piece private pieceCaptured;
        bool private castlingmove = false;

        constructor(Player _player, Spot _start, Spot _end){
            player = _player;
            start = _start;
            end = _end;
            pieceMoved = start.getPiece();
        }
    }

    enum GameStatus{
        ACTIVE,
        BLACK_WIN,
        WHITE_WIN,
        DRAW,
        STALEMATE,
        RESIGNATION
    }

    contract Game{
        Player[2] private players;
        Board private board;
        Player public currentTurn;
        GameStatus private gamestatus;
        //List<move> private movesPlayed; //broken

        function initialize(Player p1, Player p2) public {
            players[0] = p1;
            players[1] = p2;

            require(p1.isWhiteSide() != p2.isWhiteSide(), "YOU FUCKED UP!!");
            board = new Board();

            board.resetBoard();

            if(p1.isWhiteSide()){
                currentTurn = p1;
            }else{
                currentTurn = p2;
            }
        }
            //movesPlayed.clear();
        function isOver() public returns(bool){
            return this.getStatus() != GameStatus.ACTIVE;
        }

        function getStatus() public returns(GameStatus){

        }
    }