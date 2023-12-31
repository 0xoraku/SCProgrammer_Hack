## Hack

### source
[Smart Contract Programmerのtutorial](https://www.youtube.com/watch?v=4Mm3BCyHtDY&list=PLO5VPQH6OWdWsCgXJT9UuzgbC8SPvTRi5)

### Reentrancy
contract A がcontract B を呼び出すとする。 Reentrancy攻撃により、A が実行を完了する前に B が A をcallbackする。

### Arithmetic Overflow and Underflow
例えばuint8の場合、整数は2^8-1の0から255までしか表現できない。256を超えると、0に戻る。
solidityのversionが0.8.0以上の場合、オーバーフローとアンダーフローは自動的に検出されるようになった。
0.8.0未満の場合は、SafeMathを使う必要がある。

### Self Destruct

コントラクトは、selfdestruct を呼び出すことでブロックチェーンから削除できます。 selfdestruct は、コントラクトに保存されている残りの Ether をすべて指定されたアドレスに送信します。 脆弱性 悪意のあるコントラクトは、selfdestructを使用して任意のコントラクトに Ether を強制的に送信する可能性があります。但し、selfdestruct自体は非推奨で、将来的には廃止される可能性がある。

### Accessing Private Data
private修飾子などは関係なくスマートコントラクト上のすべてのデータは読み取ることができる。

### Unsafe Delegatecall
delegatecallは、他のコントラクトのコードを、現在のコントラクトのコンテキスト内で実行するために使用されます。つまり、コントラクトAがdelegatecallを使用してコントラクトBの関数を呼び出すと、その関数はコントラクトAのストレージ、バランス、および他のコンテキストで実行されます。

delegatecall を使用するときは 2 つのことに留意する必要があります 
1. delegatecall はコンテキスト (ストレージ、呼び出し元など) を保持します。
2. ストレージ レイアウトは、delegatecall を呼び出すコントラクトと呼び出されるコントラクトで同じである必要があります。

### Insecure Source of Randomness
blockhash と block.timestamp でランダム値を生成するのは危険。

### Denial of Service
ContractからのEtherの送金を拒否することによるサービス妨害。
例えば、contractにfallback関数を実装しないまま、送金するように実装する。

### Phishing with tx.origin
msg.sender と tx.origin の違いについて。
コントラクト A が B を呼び出し、B が C を呼び出す場合、C では msg.sender が B、tx.origin が A になる。
悪意のあるコントラクトは、コントラクトの所有者をだまして、その所有者のみが呼び出すことができる関数を呼び出す可能性がある。

### Hiding Malicious Code
コントラクトのコードは、Etherscanなどのブロックチェーンエクスプローラーで公開される。コントラクトのコードには、悪意のあるコードを隠すことができる。

### Honey Pot
ハニーポットはハッカーを捕まえるための罠。
例えばreentrancyとmalicious codeを組み合わせる。

### Front Running
トランザクションはマイニングされるまでに時間がかかります。攻撃者はトランザクション プールを監視してトランザクションを送信し、元のトランザクションの前のブロックにトランザクションを含めることができます。このメカニズムを悪用して、攻撃者に有利になるようにトランザクションを並べ替える可能性があります。

### Block Timestamp Manipulation
block.timestamp は、マイナーによって次の制約に従って操作されてしまいます。
- 親よりも早い時刻をスタンプすることはできません 
- それほど遠い将来のことはできません

### Signature Replay
オフチェーンでメッセージに署名し、関数を実行する前にその署名を要求するコントラクトを作成すること
ユースケース
1. オンチェーンのtransactionを減らす
2. meta transactionと呼ばれるgas-less transactionの実現
同じシグネチャを複数回使用して関数を実行できる。これは、署名者の意図がトランザクションを一度承認することだった場合に有害となる可能性がある。

### Bypass Contract Size Check
contractのsizeが0(extcodesize == 0)のコントラクトを作成する。
openzeppelinのlibraryにisContract関数があるので、これをそのまま使うのは危険。