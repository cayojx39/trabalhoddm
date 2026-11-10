# Lista de Tarefas

Aplicativo Flutter para cadastrar, priorizar e acompanhar tarefas, com persistência
local em SQLite e preferências do usuário.

## Feriados públicos

O app consulta a API pública [Nager.Date](https://date.nager.at/) sem chave de
acesso, usando os feriados do Brasil para o ano atual e o seguinte. Somente
feriados nacionais (`global == true`) são exibidos. Os resultados são armazenados
na tabela `feriados` do SQLite para consulta offline.

Na tela de cadastro, a data de entrega é opcional. Se ela coincidir com um
feriado salvo, o app exibe um aviso, mas permite salvar a tarefa. A lista e o
resumo também destacam entregas próximas de feriados.

## Executar

```shell
flutter pub get
```

No VS Code, selecione **trabalhoddm (Chrome)** na lista de configurações de
execução e pressione `F5`. O projeto usa sempre `localhost:55226`, então os
dados locais do navegador continuam disponíveis entre execuções. Evite iniciar
com uma porta aleatória ou abrir por `127.0.0.1`, pois o navegador trata esses
endereços como armazenamentos separados.
