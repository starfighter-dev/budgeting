const fs = require('fs');
const readline = require('readline');

let compare = false;
let total = 0.00;

if (process.argv.length > 2) {
    compare = process.argv[2];
}

void (async () => {
    const rl = readline.createInterface({
        input: fs.createReadStream('ledger'),
        crlfDelay: Infinity,
    });

    const lines = [];

    rl.on('line', (l) => {
        lines.unshift(l);
    });

    rl.on('close', () => {
        lines.forEach((l) => {
         if (/^  \d{2}/.test(l) || /^  --/.test(l)) {
               if ((/\| (PAID|SEND)/.test(l) && total != 0)) {
                  console.log(l);
                  console.log(`\nTotal going out: £${total.toFixed(2)}\n`);
                  if (compare) {
                     const diff = compare - total;
                     console.log(`\nYou have £${diff.toFixed(2)} left.\n`);
                  }
                  process.exit();
               }
               if (!/\| (PAID|SEND)/.test(l)) {
                  const spl = l.split('|');
                  total += parseFloat(spl[2]);
                  console.log(l);
               }
         }
        });
    });

})();
