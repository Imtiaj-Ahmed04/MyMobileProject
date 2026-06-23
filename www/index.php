<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';
$app = AppFactory::create();

// Stop your app from getting blocked by CORS errors
$app->add(function ($request, $handler) {
    return $handler->handle($request)
        ->withHeader('Access-Control-Allow-Origin', '*')
        ->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        ->withHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
});

// Your live Aiven Cloud Database configuration
function getDB() {
    $host = "mysql-3a33133d-graduate-f253.h.aivencloud.com";
    $port = "24327";
    $user = "avnadmin";
    $pass = "AVNS_hvCqAnK1mRk3Uh3jExf";
    $dbname = "defaultdb";

    $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8";
    $conn = new PDO($dsn, $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $conn;
}

// GET Endpoint to fetch items from the live cloud
$app->get('/api/items', function (Request $request, Response $response) {
    try {
        $db = getDB();
        $stmt = $db->query("SELECT * FROM items");
        $items = $stmt->fetchAll(PDO::FETCH_OBJ);
        $response->getBody()->write(json_encode($items));
        return $response->withHeader('Content-Type', 'application/json')->withStatus(200);
    } catch(Exception $e) {
        $response->getBody()->write(json_encode(["error" => $e->getMessage()]));
        return $response->withHeader('Content-Type', 'application/json')->withStatus(500);
    }
});

// POST Endpoint to save new items into the cloud
$app->post('/api/items', function (Request $request, Response $response) {
    try {
        $data = $request->getParsedBody();
        $db = getDB();
        $stmt = $db->prepare("INSERT INTO items (title, description) VALUES (?, ?)");
        $stmt->execute([$data['title'] ?? '', $data['description'] ?? '']);
        $response->getBody()->write(json_encode(["status" => "success"]));
        return $response->withHeader('Content-Type', 'application/json')->withStatus(201);
    } catch(Exception $e) {
        $response->getBody()->write(json_encode(["error" => $e->getMessage()]));
        return $response->withHeader('Content-Type', 'application/json')->withStatus(500);
    }
});

$app->options('/{routes:.+}', function ($request, $response) { return $response; });
$app->run();