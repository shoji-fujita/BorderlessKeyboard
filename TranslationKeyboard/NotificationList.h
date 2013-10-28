
// 「ACEAutocompleteInputView」からtextViewDelegateの通知とばす
//  textViewDidChange はViewControllerからもとばす
#define kTextViewShouldBeginEditing      @"textViewShouldBeginEditing"
#define kTextViewDidBeginEditing         @"textViewDidBeginEditing"
#define kTextViewShouldEndEditing        @"textViewShouldEndEditing"
#define kTextViewDidEndEditing           @"textViewDidEndEditing"
#define kTextViewShouldChangeTextInRange @"textViewShouldChangeTextInRange"
#define kTextViewDidChange               @"textViewDidChange"
#define kTextViewDidChangeSelection      @"textViewDidChangeSelection"

// 「CustomBoardView」と「StockBar」でタップされた文字の通知とばす
#define kWriteText                       @"writeText"

// 「BigTextView」でダブルタップされたら通知とばす
#define kPinchout                        @"pinchout"

// Webを出すときにキーボードを消して、辞書ボードを出す
#define kDictionaryBoardOpen             @"dictionaryBoardOpen"

// webを呼び出す
#define kWebOpen                         @"webOpen"

// ペーストボードの内容が変更されたことを通知する
#define kPasteBoardChange                @"pasteBoardChange"

// 単語登録alertViewを呼び出す
#define kWordAddOpen                     @"wordAddOpen"

// 言語バーを更新する
#define kSuggestionListReload            @"suggestionListReload"

// カスタムボードをリロードさせる
#define kCustomBoardReload               @"customBoardReload"

// 異常がないことをBigTextViewに知らせて内容をクリア
#define kClearBigTextViewText            @"clearBigTextViewText"

// アプリがフォアグラウンドになったとき翻訳バー（あれば）をファーストレスポンダにする。
#define kDidBecomeActive                 @"didBecomeActive"

// youkuMenuのタップされたボタンタグを送る
#define kTapYoukuMenu                    @"kTapYoukuMenu"

// barの位置をmiddleにする
#define kBarPositionMiddle               @"barPositionMiddle"









