class MynumberCommand {
  static get resultSuccess => [0x90, 0x00];

  static get retryResultSuccess => 0x63;

  // 公的個人認証APのselect file APDU
  static get commandSelectFile => [
        0x00,
        0xA4,
        0x04,
        0x0C,
        0x0A,
        0xD3,
        0x92,
        0xF0,
        0x00,
        0x26,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01
      ];

  // 券面入力補助AP (DF)
  static get commandTicketInputAssistance => [
        0x00,
        0xA4,
        0x04,
        0x0C,
        0x0A,
        0xD3,
        0x92,
        0x10,
        0x00,
        0x31,
        0x00,
        0x01,
        0x01,
        0x04,
        0x08
      ];

  // 券面入力補助用PIN (EF)
  static get commandTicketInputAssistancePin =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x11];

  // 証明書全体のサイズを求める APDU
  static get commandReadBinary => [0x00, 0xB0, 0x00, 0x00, 0x04];

  // PINリトライ回数をGET
  static get commandReadRetryCount => [0x00, 0x20, 0x00, 0x80];

  // 署名用PINの select file APDU
  static get commandSelectFilePinSync =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x1B];

  // 署名用証明書の select file APDU
  static get commandSelectFileCert =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x01];

  // 署名用鍵の select file APDU
  static get commandSelectFileKeySync =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x1A];

  // 認証用証明書の select file APDU
  static get commandSelectFileAuthCert =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x0A];

  // 認証用PINの select file APDU
  static get commandSelectFileAuthPin =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x18];

  // 認証用鍵の select file APDI
  static get commandSelectFileAuthKey =>
      [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x17];

  // 認証用PINの verify APDUのヘッダ
  static get commandPinVerify => [0x00, 0x20, 0x00, 0x80];

  // 暗号化用の APDU のヘッダ
  static get commandSignatureDataHeader => [0x80, 0x2A, 0x00, 0x80];

  // マイナンバー読み取り
  static get commandReadMynumber => [0x00, 0xB0, 0x00, 0x00, 0x00];

  // SELECT FILE: 基本4情報 (EF)
  static get commandBasicInfo => [0x00, 0xA4, 0x02, 0x0C, 0x02, 0x00, 0x02];

  // READ BINARY: 基本4情報の読み取り サイズのみ
  static get commandBasicInfoReadBinaryLength => [0x00, 0xB0, 0x00, 0x02, 0x01];

  // READ BINARY: 基本4情報の読み取り
  static get commandBasicInfoReadBinary => [0x00, 0xB0, 0x00, 0x00, 0x71];

  // 基本４情報名前の読み取り時のheader
  static get commandBasicInfoHeaderName => [0xDF, 0x22, 0x0F];

  // 基本４情報住所の読み取り時のheader
  static get commandBasicInfoHeaderAddress => [0xDF, 0x23, 0x39];

  // 基本４情報誕生日の読み取り時のheader
  static get commandBasicInfoHeaderBirthday => [0xDF, 0x24, 0x08];

  // 基本４情報性別読み取り時のheader
  static get commandBasicInfoHeaderGender => [0xDF, 0x25, 0x01];
}
