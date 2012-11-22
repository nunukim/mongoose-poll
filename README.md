# mongoose-poll

[Mongoose]( http://mongoosejs.com/ "リンクのタイトル") plugin to polling models

# Usage
    var poll = require('mongoose-poll');

    var schema = new mongoose.Schema({
      state: {
        type: String,
        enum: ['init', 'running']
      },
      scope: String,
      at: Date,
    });
    schema.plugin(poll, {
      path: 'state',
      sort: {at: -1},
      interval: 100,
      query: function(){return {at: {'$lte': new Date}, scope: 'scope1'};}
    });

    var Model = mongoose.model('test_model', schema);

    Model.poll('init', 'running', function(doc){
      /* do something*/
      console.log("### doc found: ", doc);
    });

    var doc = new Model( {
      state: 'init',
      scope: 'scope1',
      at: new Date(Date.now() + 5000)
    });
    doc.save()
