// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require websocket_rails/main
//= require_tree .

/*
 * Copyright 2013 Boris Smus. All Rights Reserved.

 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function onInitFs(fs, blob, options) {

    fs.root.getFile(options.name, {create: true}, function(fileEntry) {

        // Create a FileWriter object for our FileEntry (log.txt).
        fileEntry.createWriter(function(fileWriter) {

            fileWriter.onwriteend = function(e) {
                console.log('Write completed.');
            };

            fileWriter.onerror = function(e) {
                console.log('Write failed: ' + e.toString());
            };

            fileWriter.write(blob);

//            console.log(fileEntry.toURL());

            var link = document.createElement("a");
            link.download = options.name
            link.href = fileEntry.toURL();
            link.click();

        }, errorHandler);

    }, errorHandler);

}

errorHandler = function(error) {
    console.log(error);
}

function Base64toBlob(_base64)
{
    var i;
    var tmp = _base64.split(',');
    var data = atob(tmp[1]);
    var mime = tmp[0].split(':')[1].split(';')[0];

    //var buff = new ArrayBuffer(data.length);
    //var arr = new Uint8Array(buff);
    var arr = new Uint8Array(data.length);
    for (i = 0; i < data.length; i++) {arr[i] = data.charCodeAt(i);}
    var blob = new Blob([arr], { type: mime });
    return blob;
}

window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;

function DonwloadBlob(blob, options) {
    options.size = 1024 * 1024 * 1024
    window.requestFileSystem(window.TEMPORARY, options.size + 100, function(fs) {
        onInitFs(fs, blob, options);
    }, errorHandler);
}

context = new (window.AudioContext || window.webkitAudioContext)();
navigator.getUserMedia = (navigator.getUserMedia ||
    navigator.webkitGetUserMedia ||
    navigator.mozGetUserMedia ||
    navigator.msGetUserMedia);
function MicrophoneSample() {
    this.WIDTH = 640;
    this.HEIGHT = 480;
    this.getMicrophoneInput();
//    this.canvas = document.querySelector('canvas');
}

MicrophoneSample.prototype.getMicrophoneInput = function() {
    navigator.getUserMedia({audio: true},
        this.onStream.bind(this),
        this.onStreamError.bind(this));
};

MicrophoneSample.prototype.onStream = function(stream) {
    var input = context.createMediaStreamSource(stream);
    var filter = context.createBiquadFilter();
    filter.frequency.value = 60.0;
    filter.type = filter.NOTCH;
    filter.Q = 10.0;

    var analyser = context.createAnalyser();

    // Connect graph.
    input.connect(filter);
    filter.connect(analyser);

    this.analyser = analyser;
    setInterval(function() {
        var o = 0;
        var times = new Uint8Array(analyser.frequencyBinCount);
        analyser.getByteTimeDomainData(times);
        for (var i = 0; i < times.length; i++) {
            var value = Math.abs(times[i] - 128);
            o += value;
        }
        console.log(o);
    }, 1000);
    // Setup a timer to visualize some stuff.
//    requestAnimFrame(this.visualize.bind(this));
};

MicrophoneSample.prototype.onStreamError = function(e) {
    console.error('Error getting microphone', e);
};

MicrophoneSample.prototype.visualize = function() {
//    this.canvas.width = this.WIDTH;
//    this.canvas.height = this.HEIGHT;
//    var drawContext = this.canvas.getContext('2d');
    var o = 0;
    var times = new Uint8Array(this.analyser.frequencyBinCount);
    this.analyser.getByteTimeDomainData(times);
    for (var i = 0; i < times.length; i++) {
        var value = times[i];
        o += value;
//        var percent = value / 256;
//        var height = this.HEIGHT * percent;
//        var offset = this.HEIGHT - height - 1;
//        var barWidth = this.WIDTH/times.length;
//        drawContext.fillStyle = 'black';
//        drawContext.fillRect(i * barWidth, offset, 1, 1);
    }
    console.log(o);
//    requestAnimFrame(this.visualize.bind(this));
};