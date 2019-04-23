// from https://github.com/felixge/node-formidable 
// 1、安装 nodejs 
// 2、npm i -S formidable
// 3、修改本文件第一行路径
// 4、node upload.js


var formidable = require('C:\\Users\\MaxllMa\\node_modules\\formidable'),http = require('http'),util = require('util');
console.log("start upload server")
http.createServer(function(req, res) {
    // console.log(res)
    if (req.url == '/upload' && req.method.toLowerCase() == 'post') {
        // parse a file upload
        var form = new formidable.IncomingForm({'keepExtensions':true,'maxFieldsSize':24 * 1024 * 1024 * 1024,'maxFileSize':24 * 1024 * 1024 * 1024});
        form.parse(req, function(err, fields, files) {
            res.writeHead(200, {'content-type': 'text/plain'});
            res.write('received upload:\n\n');
            res.end(util.inspect({fields: fields, files: files}));
        });
        return;
    }
    // show a file upload form
    res.writeHead(200, {'content-type': 'text/html'});
    res.end(
        '<form action="/upload" enctype="multipart/form-data" method="post">'+
            '<input type="text" name="title"><br>'+
            '<input type="file" name="upload" multiple="multiple"><br>'+
            '<input type="submit" value="Upload">'+
        '</form>'
    );
    console.log("finish");
}).listen(8080);

