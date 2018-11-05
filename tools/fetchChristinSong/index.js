const to = require('await-to-js').to,
axios = require('axios'),
cheerio = require('cheerio'),
fse = require('fs-extra');

const startNum = process.env.START;
let endNum = process.env.STOP;
const hymnDir = process.env.DIR;

console.log(`starting at .. ${startNum} & ending at ... ${endNum}`)

// process.exit();
async function fetchpage(songNum){
	let url = `https://hymnary.org/hymn/CSR1908/${songNum}#text`
	return new Promise(function(resolve, reject) {
	    axios.get(url)
		.then(function (response) {
			let $ = cheerio.load(response.data);

            let title, nextNumber;
            let hymnInfo = {}
            let keys = [],
            	vals = []

            $('#standard-hymn-page').filter(function(){


                let data = $(this);


                title = data.children().first().text();
                // let nexthymn = next-hymn-number
                $('.next-hymn-number').filter(function(){
                	nextNumber = $(this).children().first().text()
                	// console.log('next hymn next-hymn-number')
                	// console.log($(this).children().first().text())
                });

                $('.hy_infoItem').each(function(i, elem) {
				  // console.log($(this).children().first().text() || $(this).text());
				  vals.push($(this).children().first().text() || $(this).text())
				});

				$('.hy_infoLabel').each(function(i, elem) {
					keys.push($(this).children().first().text() || $(this).text())
				  // console.log($(this).children().first().text() || $(this).text());
				});

				for(let i in keys)
					hymnInfo[keys[i]] = vals[i]
				// console.log(hymnInfo)

				let stanzas = []
				$('#text').filter(function(){
                	$(this).children().each(function(i, elem) {
					  stanzas.push($(this).text())
					});

                });
				hymnInfo['stanzas'] = stanzas
                // console.log(stanzas)
                hymnInfo['nexthymn'] = nextNumber

            })

			return resolve(hymnInfo);
		})
		.catch(function (error) {
			return reject(error);
		});
	});
}


let hymnNumber = startNum;


async function main(){
	let [err, care] = await to(fetchpage(hymnNumber))
	if (err) {

	} else {
		// for(let i in care)
			// console.log(i)
		let hymnnum = ''+parseInt(hymnNumber);
		endNum = ''+endNum;
		// console.log(`${hymnnum.length} vs ${endNum.length}`)
		while(hymnnum.length < endNum.length) hymnnum = '0' + hymnnum
		// if()
	// console.log(`${hymnnum} vs ${endNum}`)
	// console.log(`${hymnnum.length} vs ${endNum.length}`)
		hymnNumber = care.nexthymn;
		let hymntxt = ''
		let firstLine = `${hymnnum} – ${care['Title:'] || care.Title}`
		hymntxt += firstLine + '\n\n\n'
		// console.log(hymntxt)
		for(let i in care.stanzas) {
			let stanza = care.stanzas[i];
			if(!isNaN(stanza[0])) {
				let regex = / /;
				stanza = stanza.replace(regex, '\n')
			}
			hymntxt += stanza + '\n'
			// let tmp = stanza.match(/\+CLI(.)*/ig);

		}

		async function saveHymn(location, data) {
			return new Promise(function(resolve, reject) {
				fse.writeFile(location, data, function(err) {
			      if(err) {
			          return reject(err)
			      }
			      resolve();
			    });
			   })
		}


		let location = `${hymnDir}/songs/${hymnnum}.txt`
		console.log(location)
		let [err1, care1] = []
		// let [err1, care1] = await to(saveHymn(location, hymntxt))
		// console.log(err1)
		// console.log(care)
		let header = 'Key | Author   | Specific Bible Passage     |Hymn Date |Author\'s life |Tune |Metrical Pattern   |Composer/Source\n'
		header += '-- | --------- | ---------------------------|----------|--------------|-----|-------------------|-------------  \n'
		header += care['Key:'] || '-'
		header+= ' |' 
		header += care['Author:'] || '-'
		header+= ' |'
		header += care['Scripture:'] || '-'
		header+= ' |'
		header += care['Publication Date:'] || '-'
		header+= ' |'
		header += '-'
		header+= ' |'
		header += care['Name:'] || '-'
		header+= ' |'
		header += '-'
		header+= ' |'
		header += care['Composer:'] || '-'
		header+= '\n\n'
		header += 'Original Language | Translater | Translation Date   | Translater\'s Life  \n'
		header += '----------------- | --------- | --------------------|-------------     \n'
		header += care['Original Language:'] || '\\-'
		header+= ' |'
		header += '-'
		header+= ' |'
		header += '-'
		header+= ' |'
		header += '-'
		header+= '\n'

		location = `${hymnDir}/songheaders/${hymnnum}.md`
		console.log(location)
		;[err1, care1] = await to(saveHymn(location, header))
		console.log(err1)

		console.log(header)
		if(!isNaN(hymnNumber)) {
			// we will continue
			// console.log(hymnNumber)
			await main();

		}
		// console.log(hymntxt)
	}


	// console.log(care.data)
	console.log(err)
}

main()
 

