var _ = require('underscore')
var request = require('superagent');
var wrap = require('word-wrap');
var urlEncode = require('urlencode');
var parser = require('xml2json');
var debug = require('debug')("ieee")

var $b = require('bluebird')

var ieeeSearch = () => {
    var qt = []
    var pubs = []

    function addKeywords(keywords, isTitle) {
		debug(`keywords = ${keywords} - isTitle = ${isTitle}`)
        if (!_.isArray(keywords)) {
            keywords = [keywords]
        }
        if (isTitle) {
            keywords = _.map(keywords, (it) => {
                return `"Document Title":${it}`
            })
        }
		qt = keywords
    }

    function searchPubs(dt) {
        if (_.isArray(dt)) {
            pubs = pubs.concat(dt)
        } else {
            pubs = pubs.concat([dt])
        }
    }

    function sendRequest(batchsize, batchnumber) {
        pubs = _.map(pubs, (s) => {
            return `"Publication Title":${s}`
        })

        var tquery = `(${qt.join(' OR ')})`
        var cquery = `${([tquery].concat(pubs)).join(' AND ')}`
        var reqOptions = {
            hc: batchsize,
            sortfield: "py",
            sortorder: "desc",
            querytext: cquery
        }
        var ie = "http://ieeexplore.ieee.org/gateway/ipsSearch.jsp?"
        var url = `${ie}${urlEncode.stringify(reqOptions)}`

        return new $b((resolve) => {
			debug(url)
            request.get(url).end((err,res) => {
                var data = parser.toJson(res.text, {
                    object: true
                })
                resolve(data.root.document)

            })
        })
    }

    return {
        addKeywords, searchPubs, sendRequest
    }
}

module.exports = ieeeSearch()
