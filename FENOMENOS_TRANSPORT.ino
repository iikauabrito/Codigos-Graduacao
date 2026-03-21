#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ElegantOTA.h>
#include <Preferences.h>

#define TRIG 5
#define ECHO 18

AsyncWebServer server(80);
Preferences prefs;

String ssid="";
String pass="";

float distancia=0;
float referencia=0;
float volume=0;
float raio=10;

float medirDistancia(){

long duracao;

digitalWrite(TRIG,LOW);
delayMicroseconds(2);

digitalWrite(TRIG,HIGH);
delayMicroseconds(10);
digitalWrite(TRIG,LOW);

duracao = pulseIn(ECHO,HIGH,30000);

float d = duracao*0.0343/2;

return d;

}

float calcVolume(float h){

return 3.1416*raio*raio*h;

}

void iniciarAP(){

WiFi.mode(WIFI_AP);
WiFi.softAP("ESP_SETUP");

Serial.println("AP criado");
Serial.println(WiFi.softAPIP());

}

void conectarWifi(){

prefs.begin("wifi",true);

ssid = prefs.getString("ssid","");
pass = prefs.getString("pass","");

prefs.end();

if(ssid!=""){

WiFi.mode(WIFI_STA);
WiFi.begin(ssid.c_str(),pass.c_str());

int t=0;

while(WiFi.status()!=WL_CONNECTED && t<20){

delay(1000);
Serial.print(".");
t++;

}

if(WiFi.status()==WL_CONNECTED){

Serial.println("");
Serial.println(WiFi.localIP());

}
else{

iniciarAP();

}

}
else{

iniciarAP();

}

}
String pagina(){

String html = R"rawliteral(

<!DOCTYPE html>
<html>

<head>

<meta name="viewport" content="width=device-width, initial-scale=1">

<style>

body{
font-family:Arial;
background:#0f172a;
color:white;
text-align:center;
}

h1{
color:#38bdf8;
}

.container{
display:flex;
flex-wrap:wrap;
justify-content:center;
gap:20px;
}

.card{
background:#1e293b;
padding:20px;
border-radius:10px;
width:300px;
}

input{
padding:8px;
margin:5px;
width:200px;
}

button{
padding:10px;
background:#38bdf8;
border:none;
border-radius:6px;
cursor:pointer;
}

.tanque{
width:120px;
height:300px;
border:4px solid white;
border-radius:10px;
margin:auto;
position:relative;
overflow:hidden;
}

.nivel{
position:absolute;
bottom:0;
width:100%;
background:#3b82f6;
height:0%;
transition:0.5s;
}

.valor{
font-size:20px;
margin-top:10px;
}

</style>

<script>

function atualizar(){

fetch("/data")
.then(r=>r.json())
.then(data=>{

document.getElementById("dist").innerHTML=data.dist+" cm";
document.getElementById("vol").innerHTML=data.vol+" litros";

let nivel = data.nivel;
document.getElementById("nivel").style.height=nivel+"%";

});

}

setInterval(atualizar,2000);

</script>

</head>

<body>

<h1>Transport Phenomena</h1>
<h3>Monitoramento de tanque</h3>

<div class="container">

<div class="card">

<h2>Tanque</h2>

<div class="tanque">
<div class="nivel" id="nivel"></div>
</div>

</div>

<div class="card">

<h2>Medicoes</h2>

<div class="valor">
Distancia do sensor: <span id="dist">0</span>
</div>

<div class="valor">
Volume calculado: <span id="vol">0</span>
</div>

<div class="valor">
Unidades utilizadas:
<br>
Distancia = cm
<br>
Raio = cm
<br>
Volume = litros
</div>

</div>

<div class="card">

<h2>Configuracao do tanque</h2>

<form action="/setraio">
<input name="raio" placeholder="Raio do cilindro (cm)">
<button>Salvar raio</button>
</form>

<form action="/setref">
<button>Definir referencia do tanque</button>
</form>

</div>

<div class="card">

<h2>Configuracao WiFi</h2>

<form action="/setwifi">

<input name="ssid" placeholder="Nome da rede"><br>
<input name="pass" placeholder="Senha da rede"><br>

<button>Salvar WiFi</button>

</form>

</div>

<div class="card">

<h2>Atualizacao de firmware</h2>

<a href="/update">
<button>Atualizar firmware OTA</button>
</a>

</div>

</div>

<br>

Contato: caua.brito@estudante.cear.ufpb.br

</body>

</html>

)rawliteral";

return html;

}
void setup(){

Serial.begin(115200);

pinMode(TRIG,OUTPUT);
pinMode(ECHO,INPUT);

conectarWifi();

server.on("/",HTTP_GET,[](AsyncWebServerRequest *req){

req->send(200,"text/html",pagina());

});

server.on("/data",HTTP_GET,[](AsyncWebServerRequest *req){

float nivel = (referencia - distancia)/referencia * 100;

if(nivel < 0) nivel = 0;
if(nivel > 100) nivel = 100;

String json="{";

json+="\"dist\":"+String(distancia)+",";
json+="\"vol\":"+String(volume)+",";
json+="\"nivel\":"+String(nivel);

json+="}";

req->send(200,"application/json",json);

});

server.on("/setref",HTTP_GET,[](AsyncWebServerRequest *req){

referencia = distancia;

req->redirect("/");

});

server.on("/setraio",HTTP_GET,[](AsyncWebServerRequest *req){

raio = req->getParam("raio")->value().toFloat();

req->redirect("/");

});

server.on("/setwifi",HTTP_GET,[](AsyncWebServerRequest *req){

ssid = req->getParam("ssid")->value();
pass = req->getParam("pass")->value();

prefs.begin("wifi",false);

prefs.putString("ssid",ssid);
prefs.putString("pass",pass);

prefs.end();

req->send(200,"text/plain","WiFi saved. Restart ESP.");

});

ElegantOTA.begin(&server);

server.begin();

}

void loop(){

distancia = medirDistancia();

float alturaTanque = referencia; 
float h = alturaTanque - distancia;

if(h<0) h=0;

volume = calcVolume(h)/1000;

ElegantOTA.loop();

delay(500);

}
