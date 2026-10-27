# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A focused launcher for your desktop — native, fast, extensible"
HOMEPAGE="https://github.com/vicinaehq/vicinae"
SRC_URI="https://github.com/vicinaehq/vicinae/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/vicinaehq/numen/archive/refs/tags/v0.8.1.tar.gz -> ${P}-numen-0.8.1.tar.gz"

NPM_REGISTRY_URI="https://registry.npmjs.org"
NPM_DISTFILES="
	${P}-npm-6e4f208e55cf0d377e64.tgz
	${P}-npm-1663b9dbc76a03afd1b9.tgz
	${P}-npm-ee9e537526cc6d1f8afb.tgz
	${P}-npm-0466e61b16fcd188fb19.tgz
	${P}-npm-d63b028e4fdd8f649921.tgz
	${P}-npm-1e7f122f66805f784afe.tgz
	${P}-npm-ce495cd58eb95125c951.tgz
	${P}-npm-a182efb83ad9c1f6056f.tgz
	${P}-npm-dc7b212f2c59021dd6b0.tgz
	${P}-npm-374f2b37249b3d09eac0.tgz
	${P}-npm-4add22f03b1916266bba.tgz
	${P}-npm-b04ef2520a9ca3f0e625.tgz
	${P}-npm-38ee8cb60211ba78f2b6.tgz
	${P}-npm-66b23e70d4e22eb400c8.tgz
	${P}-npm-3947810f4c0018812ce3.tgz
	${P}-npm-ec5877ed18a11e225138.tgz
	${P}-npm-3c8d5d54af3cad119a9a.tgz
	${P}-npm-cc5204e929e3f376026a.tgz
	${P}-npm-245cd6ce08988afc3f69.tgz
	${P}-npm-8645fee083179987102b.tgz
	${P}-npm-2b81b7f258eeff2675cf.tgz
	${P}-npm-6b882a98d03a3d17a21f.tgz
	${P}-npm-45f3c5867a361342b130.tgz
	${P}-npm-26b4625f3044eccb68f8.tgz
	${P}-npm-cff6f94978fb790bf93c.tgz
	${P}-npm-f10386fcecf630e20854.tgz
	${P}-npm-61810eb7011322ff6628.tgz
	${P}-npm-8b87ad5636a59d94df4c.tgz
	${P}-npm-da0f675dc7f42539b062.tgz
	${P}-npm-58646b8a59d29705f0c9.tgz
	${P}-npm-c139a642e52a16e1d016.tgz
	${P}-npm-fc689a485bf8a0296a5d.tgz
	${P}-npm-df8358eeeeb6389348b4.tgz
	${P}-npm-7b09c49ed17c7dc46398.tgz
	${P}-npm-dcbb02c2d76abbb6cf0b.tgz
	${P}-npm-1ed4db8cbfaf0911a394.tgz
	${P}-npm-45b7183fb272447fca79.tgz
	${P}-npm-26b82eee54c08b2ed297.tgz
	${P}-npm-d9bbb8231971367e0539.tgz
	${P}-npm-3d4e31d18adb1ef2a474.tgz
	${P}-npm-0d628a1c7bfcf3265189.tgz
	${P}-npm-bf0bdfb9bb777e9bbe52.tgz
	${P}-npm-9fad61a330853c717459.tgz
	${P}-npm-51838b8c6bffeaa838b8.tgz
	${P}-npm-8e0b43e6a7ce84b727b8.tgz
	${P}-npm-1d77eb92512445f2100e.tgz
	${P}-npm-ab9c5770708ff1bfa9eb.tgz
	${P}-npm-93c437d744350d95c5c4.tgz
	${P}-npm-6497f02ab1ffbbb4f643.tgz
	${P}-npm-03d7ec3e8752e3151ec3.tgz
	${P}-npm-e8bad89ecbdd2063b8c1.tgz
	${P}-npm-26e541a39146983a6918.tgz
	${P}-npm-6c7100c211bc437bc392.tgz
	${P}-npm-331d9fd87efb11afa2eb.tgz
	${P}-npm-971ebb74c5f683606201.tgz
	${P}-npm-13286db5ec49d99d2051.tgz
	${P}-npm-2a4fb3ace2642cfe2de9.tgz
	${P}-npm-0cbcfd98fa641bfe809a.tgz
	${P}-npm-f2bdfe6c228b6592932d.tgz
	${P}-npm-5dca37d76957dc239786.tgz
	${P}-npm-634654bbbce94378e3a1.tgz
	${P}-npm-51757e3064e830afe2d8.tgz
	${P}-npm-2e4636259258e6c55107.tgz
	${P}-npm-2fa0d4bd3b43f73b542d.tgz
	${P}-npm-dbd33e19d7e5835d188a.tgz
	${P}-npm-cffb53f16b20a8f073cb.tgz
	${P}-npm-4580cc6668f74af2efc1.tgz
	${P}-npm-1f5bc6ae0d0df257b9f0.tgz
	${P}-npm-b4ef699c1649cd509cdf.tgz
	${P}-npm-b340c368678545c05a72.tgz
	${P}-npm-3f28b0af10c25d549c5b.tgz
	${P}-npm-8d7f38d4cd92a15a14e6.tgz
	${P}-npm-dd2d1e1450fb9096f454.tgz
	${P}-npm-7b899987537cdb5007fe.tgz
	${P}-npm-7941a5461295a0ceaf0b.tgz
	${P}-npm-443535fb8cb143a477f5.tgz
	${P}-npm-b11274c4ab3b02a855ab.tgz
	${P}-npm-7cd4d0c373ab5f91c75f.tgz
	${P}-npm-8a8bb4fcb198182af6f1.tgz
	${P}-npm-58c7bc9c5ab583a508aa.tgz
	${P}-npm-b5d2dfa167d4e958364e.tgz
	${P}-npm-7b1a32aa4d9b98523d5d.tgz
	${P}-npm-f3bb75392d5057a5b86c.tgz
	${P}-npm-9d0736a298780db2c067.tgz
	${P}-npm-da9efeb900abbd5bbbf3.tgz
	${P}-npm-20086cdd9509b3b0de97.tgz
	${P}-npm-f03a63f61d771cdef083.tgz
	${P}-npm-323b50ee9f8469b4f412.tgz
	${P}-npm-3d2da65d451edb401740.tgz
	${P}-npm-cc0d58ecfce55b065ea8.tgz
	${P}-npm-38a010cd95990c694d38.tgz
	${P}-npm-9d3d70bcb03ef0d1c988.tgz
	${P}-npm-cd9479e378076e3f3035.tgz
	${P}-npm-bf9cd39664db72ab2195.tgz
	${P}-npm-d6ed705e51bb874c9ec3.tgz
	${P}-npm-0943dd15c789917b8b34.tgz
	${P}-npm-a87a387232d81bdd1427.tgz
	${P}-npm-a5e652e3eba14d7a74a6.tgz
	${P}-npm-feb44518b72bf43373e6.tgz
	${P}-npm-dc3c987d484e7276a341.tgz
	${P}-npm-196757ee5bcda0ae690c.tgz
	${P}-npm-0c4ae90c4b5b005d7fa6.tgz
	${P}-npm-e926f9f530b37f49af1b.tgz
	${P}-npm-65f1b46c600f005d7005.tgz
	${P}-npm-8758b32dbb482885010d.tgz
	${P}-npm-3d86972e665a2ed34286.tgz
	${P}-npm-7f1f904879825b70e538.tgz
	${P}-npm-00ccf7924483f951f252.tgz
	${P}-npm-9633d19f762f3e5ac9a3.tgz
	${P}-npm-06d75a9f2d46221b54c7.tgz
	${P}-npm-df07031725d01d818b97.tgz
	${P}-npm-75c06f2878a0df345abf.tgz
	${P}-npm-636f8f44fb48c0871a4d.tgz
	${P}-npm-a712176a765ddcf398b6.tgz
	${P}-npm-3040cf19dd88777068e6.tgz
	${P}-npm-1eac42508e0922c2e40c.tgz
	${P}-npm-a1e7de6dcc3e5b0f071e.tgz
	${P}-npm-c1e07c0e9d59160dd8aa.tgz
	${P}-npm-9f13fd4b6f858c06f212.tgz
	${P}-npm-78312f0b0c4ee480a953.tgz
	${P}-npm-52244350e6a7cab5116b.tgz
	${P}-npm-61244407122d480a5102.tgz
	${P}-npm-31cc4b9709f2960caa1e.tgz
	${P}-npm-e63e46e168ef8f94649d.tgz
	${P}-npm-2afa5a18461d5ffca005.tgz
	${P}-npm-21df1729e12558a034f5.tgz
	${P}-npm-03ae75f42a2d7fac7c59.tgz
	${P}-npm-d2e83e5b4b1e5a8a88f3.tgz
	${P}-npm-bd765d2d414902f847fc.tgz
	${P}-npm-c2ae67e1facf31ad5db3.tgz
	${P}-npm-3e412b1535d574473797.tgz
	${P}-npm-deabc134826449b44cfd.tgz
	${P}-npm-9e0ec80f930cf33cf228.tgz
	${P}-npm-36e6f13e9211ea02bf0d.tgz
	${P}-npm-10badbb7cf8767c1365e.tgz
	${P}-npm-6c69857c9c572d855542.tgz
	${P}-npm-439f35e68fbcc131e984.tgz
	${P}-npm-d90295519b7547d2593a.tgz
	${P}-npm-efceb9eb7225dfe81818.tgz
	${P}-npm-98048b77ecadcb357f14.tgz
	${P}-npm-154e71457695092ef25b.tgz
	${P}-npm-a924e42e3d160d6c137d.tgz
	${P}-npm-3e3847482dc09da6c228.tgz
	${P}-npm-a2826fe8d61d9deb5019.tgz
	${P}-npm-58c451c81400e8cd33b1.tgz
	${P}-npm-9d08ed98feb2fac85abc.tgz
	${P}-npm-2b565d463ed1ca9b3a3b.tgz
	${P}-npm-b255b72625085d5d4c44.tgz
	${P}-npm-e043c2b4910c8d8d295b.tgz
	${P}-npm-7cdadb77905522544408.tgz
	${P}-npm-c822af38d8df3d8cf0b3.tgz
	${P}-npm-6be5bdf1b5aeb8b490de.tgz
	${P}-npm-11e85bb5d8fc9fd2e761.tgz
	${P}-npm-f7503865577c3206d087.tgz
	${P}-npm-113ed8574a49cd132909.tgz
	${P}-npm-7db69a73f22acf0f5fb8.tgz
	${P}-npm-eb8696fde33f5986cc9b.tgz
	${P}-npm-65d9080aa6b2fd60317b.tgz
	${P}-npm-1fc9dd02bcc5d7d12821.tgz
	${P}-npm-ea032fcef93c5f75240b.tgz
	${P}-npm-8718b3ce2bb46e861f61.tgz
	${P}-npm-185205cf34138b24a45e.tgz
	${P}-npm-2f6952617f0407047b98.tgz
	${P}-npm-f9e0119859209c62f539.tgz
	${P}-npm-c9ccbffeede1b29dbb0b.tgz
	${P}-npm-e76388d10737ee5aa8e3.tgz
	${P}-npm-49b60b56de36c50069ca.tgz
	${P}-npm-6b8a76f896ee29733609.tgz
	${P}-npm-8c2dc136cfbb6534d507.tgz
	${P}-npm-a8a920d48b7486d316df.tgz
	${P}-npm-3064cdf6cd65e8e1791e.tgz
	${P}-npm-e978fdb05ffa0ce9bdfc.tgz
	${P}-npm-74746a78e6d7b049a3ab.tgz
	${P}-npm-078cb1fc9c2b9d6cc6f1.tgz
	${P}-npm-b59e37abaa74ad5f5eb7.tgz
	${P}-npm-8303e7905cdb50de9d22.tgz
	${P}-npm-8fb567ff6e1b5ca41a78.tgz
	${P}-npm-6fa276b5f4a3e3cfb051.tgz
	${P}-npm-9766eded13ec7334018a.tgz
	${P}-npm-3353ed507040c5ab035d.tgz
	${P}-npm-5e69e6770447e1e0282f.tgz
"
NPM_SRC_URI="
	${NPM_REGISTRY_URI}/@biomejs/biome/-/biome-2.3.2.tgz
		-> ${P}-npm-6e4f208e55cf0d377e64.tgz
	${NPM_REGISTRY_URI}/@biomejs/cli-linux-x64-musl/-/cli-linux-x64-musl-2.3.2.tgz
		-> ${P}-npm-1663b9dbc76a03afd1b9.tgz
	${NPM_REGISTRY_URI}/@biomejs/cli-linux-x64/-/cli-linux-x64-2.3.2.tgz
		-> ${P}-npm-ee9e537526cc6d1f8afb.tgz
	${NPM_REGISTRY_URI}/@esbuild/linux-x64/-/linux-x64-0.25.12.tgz
		-> ${P}-npm-0466e61b16fcd188fb19.tgz
	${NPM_REGISTRY_URI}/@esbuild/linux-x64/-/linux-x64-0.25.9.tgz
		-> ${P}-npm-d63b028e4fdd8f649921.tgz
	${NPM_REGISTRY_URI}/@types/node/-/node-22.17.2.tgz
		-> ${P}-npm-1e7f122f66805f784afe.tgz
	${NPM_REGISTRY_URI}/@types/node/-/node-24.3.0.tgz
		-> ${P}-npm-ce495cd58eb95125c951.tgz
	${NPM_REGISTRY_URI}/@types/react-reconciler/-/react-reconciler-0.32.1.tgz
		-> ${P}-npm-a182efb83ad9c1f6056f.tgz
	${NPM_REGISTRY_URI}/@types/react/-/react-19.1.17.tgz
		-> ${P}-npm-dc7b212f2c59021dd6b0.tgz
	${NPM_REGISTRY_URI}/ansi-styles/-/ansi-styles-3.2.1.tgz
		-> ${P}-npm-374f2b37249b3d09eac0.tgz
	${NPM_REGISTRY_URI}/anymatch/-/anymatch-3.1.3.tgz
		-> ${P}-npm-4add22f03b1916266bba.tgz
	${NPM_REGISTRY_URI}/array-buffer-byte-length/-/array-buffer-byte-length-1.0.2.tgz
		-> ${P}-npm-b04ef2520a9ca3f0e625.tgz
	${NPM_REGISTRY_URI}/arraybuffer.prototype.slice/-/arraybuffer.prototype.slice-1.0.4.tgz
		-> ${P}-npm-38ee8cb60211ba78f2b6.tgz
	${NPM_REGISTRY_URI}/async-function/-/async-function-1.0.0.tgz
		-> ${P}-npm-66b23e70d4e22eb400c8.tgz
	${NPM_REGISTRY_URI}/available-typed-arrays/-/available-typed-arrays-1.0.7.tgz
		-> ${P}-npm-3947810f4c0018812ce3.tgz
	${NPM_REGISTRY_URI}/balanced-match/-/balanced-match-1.0.2.tgz
		-> ${P}-npm-ec5877ed18a11e225138.tgz
	${NPM_REGISTRY_URI}/binary-extensions/-/binary-extensions-2.3.0.tgz
		-> ${P}-npm-3c8d5d54af3cad119a9a.tgz
	${NPM_REGISTRY_URI}/brace-expansion/-/brace-expansion-1.1.15.tgz
		-> ${P}-npm-cc5204e929e3f376026a.tgz
	${NPM_REGISTRY_URI}/braces/-/braces-3.0.3.tgz
		-> ${P}-npm-245cd6ce08988afc3f69.tgz
	${NPM_REGISTRY_URI}/call-bind-apply-helpers/-/call-bind-apply-helpers-1.0.2.tgz
		-> ${P}-npm-8645fee083179987102b.tgz
	${NPM_REGISTRY_URI}/call-bind/-/call-bind-1.0.9.tgz
		-> ${P}-npm-2b81b7f258eeff2675cf.tgz
	${NPM_REGISTRY_URI}/call-bound/-/call-bound-1.0.4.tgz
		-> ${P}-npm-6b882a98d03a3d17a21f.tgz
	${NPM_REGISTRY_URI}/chalk/-/chalk-2.4.2.tgz
		-> ${P}-npm-45f3c5867a361342b130.tgz
	${NPM_REGISTRY_URI}/chokidar/-/chokidar-3.6.0.tgz
		-> ${P}-npm-26b4625f3044eccb68f8.tgz
	${NPM_REGISTRY_URI}/chokidar/-/chokidar-4.0.3.tgz
		-> ${P}-npm-cff6f94978fb790bf93c.tgz
	${NPM_REGISTRY_URI}/color-convert/-/color-convert-1.9.3.tgz
		-> ${P}-npm-f10386fcecf630e20854.tgz
	${NPM_REGISTRY_URI}/color-name/-/color-name-1.1.3.tgz
		-> ${P}-npm-61810eb7011322ff6628.tgz
	${NPM_REGISTRY_URI}/concat-map/-/concat-map-0.0.1.tgz
		-> ${P}-npm-8b87ad5636a59d94df4c.tgz
	${NPM_REGISTRY_URI}/cross-spawn/-/cross-spawn-6.0.6.tgz
		-> ${P}-npm-da0f675dc7f42539b062.tgz
	${NPM_REGISTRY_URI}/csstype/-/csstype-3.2.3.tgz
		-> ${P}-npm-58646b8a59d29705f0c9.tgz
	${NPM_REGISTRY_URI}/data-view-buffer/-/data-view-buffer-1.0.2.tgz
		-> ${P}-npm-c139a642e52a16e1d016.tgz
	${NPM_REGISTRY_URI}/data-view-byte-length/-/data-view-byte-length-1.0.2.tgz
		-> ${P}-npm-fc689a485bf8a0296a5d.tgz
	${NPM_REGISTRY_URI}/data-view-byte-offset/-/data-view-byte-offset-1.0.1.tgz
		-> ${P}-npm-df8358eeeeb6389348b4.tgz
	${NPM_REGISTRY_URI}/debug/-/debug-4.4.3.tgz
		-> ${P}-npm-7b09c49ed17c7dc46398.tgz
	${NPM_REGISTRY_URI}/define-data-property/-/define-data-property-1.1.4.tgz
		-> ${P}-npm-dcbb02c2d76abbb6cf0b.tgz
	${NPM_REGISTRY_URI}/define-properties/-/define-properties-1.2.1.tgz
		-> ${P}-npm-1ed4db8cbfaf0911a394.tgz
	${NPM_REGISTRY_URI}/dunder-proto/-/dunder-proto-1.0.1.tgz
		-> ${P}-npm-45b7183fb272447fca79.tgz
	${NPM_REGISTRY_URI}/error-ex/-/error-ex-1.3.4.tgz
		-> ${P}-npm-26b82eee54c08b2ed297.tgz
	${NPM_REGISTRY_URI}/es-abstract-get/-/es-abstract-get-1.0.0.tgz
		-> ${P}-npm-d9bbb8231971367e0539.tgz
	${NPM_REGISTRY_URI}/es-abstract/-/es-abstract-1.24.2.tgz
		-> ${P}-npm-3d4e31d18adb1ef2a474.tgz
	${NPM_REGISTRY_URI}/es-define-property/-/es-define-property-1.0.1.tgz
		-> ${P}-npm-0d628a1c7bfcf3265189.tgz
	${NPM_REGISTRY_URI}/es-errors/-/es-errors-1.3.0.tgz
		-> ${P}-npm-bf0bdfb9bb777e9bbe52.tgz
	${NPM_REGISTRY_URI}/es-object-atoms/-/es-object-atoms-1.1.2.tgz
		-> ${P}-npm-9fad61a330853c717459.tgz
	${NPM_REGISTRY_URI}/es-set-tostringtag/-/es-set-tostringtag-2.1.0.tgz
		-> ${P}-npm-51838b8c6bffeaa838b8.tgz
	${NPM_REGISTRY_URI}/es-to-primitive/-/es-to-primitive-1.3.4.tgz
		-> ${P}-npm-8e0b43e6a7ce84b727b8.tgz
	${NPM_REGISTRY_URI}/esbuild/-/esbuild-0.25.12.tgz
		-> ${P}-npm-1d77eb92512445f2100e.tgz
	${NPM_REGISTRY_URI}/esbuild/-/esbuild-0.25.9.tgz
		-> ${P}-npm-ab9c5770708ff1bfa9eb.tgz
	${NPM_REGISTRY_URI}/escape-string-regexp/-/escape-string-regexp-1.0.5.tgz
		-> ${P}-npm-93c437d744350d95c5c4.tgz
	${NPM_REGISTRY_URI}/fill-range/-/fill-range-7.1.1.tgz
		-> ${P}-npm-6497f02ab1ffbbb4f643.tgz
	${NPM_REGISTRY_URI}/for-each/-/for-each-0.3.5.tgz
		-> ${P}-npm-03d7ec3e8752e3151ec3.tgz
	${NPM_REGISTRY_URI}/function-bind/-/function-bind-1.1.2.tgz
		-> ${P}-npm-e8bad89ecbdd2063b8c1.tgz
	${NPM_REGISTRY_URI}/function.prototype.name/-/function.prototype.name-1.2.0.tgz
		-> ${P}-npm-26e541a39146983a6918.tgz
	${NPM_REGISTRY_URI}/functions-have-names/-/functions-have-names-1.2.3.tgz
		-> ${P}-npm-6c7100c211bc437bc392.tgz
	${NPM_REGISTRY_URI}/generator-function/-/generator-function-2.0.1.tgz
		-> ${P}-npm-331d9fd87efb11afa2eb.tgz
	${NPM_REGISTRY_URI}/get-intrinsic/-/get-intrinsic-1.3.0.tgz
		-> ${P}-npm-971ebb74c5f683606201.tgz
	${NPM_REGISTRY_URI}/get-proto/-/get-proto-1.0.1.tgz
		-> ${P}-npm-13286db5ec49d99d2051.tgz
	${NPM_REGISTRY_URI}/get-symbol-description/-/get-symbol-description-1.1.0.tgz
		-> ${P}-npm-2a4fb3ace2642cfe2de9.tgz
	${NPM_REGISTRY_URI}/glob-parent/-/glob-parent-5.1.2.tgz
		-> ${P}-npm-0cbcfd98fa641bfe809a.tgz
	${NPM_REGISTRY_URI}/globalthis/-/globalthis-1.0.4.tgz
		-> ${P}-npm-f2bdfe6c228b6592932d.tgz
	${NPM_REGISTRY_URI}/gopd/-/gopd-1.2.0.tgz
		-> ${P}-npm-5dca37d76957dc239786.tgz
	${NPM_REGISTRY_URI}/graceful-fs/-/graceful-fs-4.2.11.tgz
		-> ${P}-npm-634654bbbce94378e3a1.tgz
	${NPM_REGISTRY_URI}/has-bigints/-/has-bigints-1.1.0.tgz
		-> ${P}-npm-51757e3064e830afe2d8.tgz
	${NPM_REGISTRY_URI}/has-flag/-/has-flag-3.0.0.tgz
		-> ${P}-npm-2e4636259258e6c55107.tgz
	${NPM_REGISTRY_URI}/has-property-descriptors/-/has-property-descriptors-1.0.2.tgz
		-> ${P}-npm-2fa0d4bd3b43f73b542d.tgz
	${NPM_REGISTRY_URI}/has-proto/-/has-proto-1.2.0.tgz
		-> ${P}-npm-dbd33e19d7e5835d188a.tgz
	${NPM_REGISTRY_URI}/has-symbols/-/has-symbols-1.1.0.tgz
		-> ${P}-npm-cffb53f16b20a8f073cb.tgz
	${NPM_REGISTRY_URI}/has-tostringtag/-/has-tostringtag-1.0.2.tgz
		-> ${P}-npm-4580cc6668f74af2efc1.tgz
	${NPM_REGISTRY_URI}/hasown/-/hasown-2.0.4.tgz
		-> ${P}-npm-1f5bc6ae0d0df257b9f0.tgz
	${NPM_REGISTRY_URI}/hosted-git-info/-/hosted-git-info-2.8.9.tgz
		-> ${P}-npm-b4ef699c1649cd509cdf.tgz
	${NPM_REGISTRY_URI}/ignore-by-default/-/ignore-by-default-1.0.1.tgz
		-> ${P}-npm-b340c368678545c05a72.tgz
	${NPM_REGISTRY_URI}/internal-slot/-/internal-slot-1.1.0.tgz
		-> ${P}-npm-3f28b0af10c25d549c5b.tgz
	${NPM_REGISTRY_URI}/is-array-buffer/-/is-array-buffer-3.0.5.tgz
		-> ${P}-npm-8d7f38d4cd92a15a14e6.tgz
	${NPM_REGISTRY_URI}/is-arrayish/-/is-arrayish-0.2.1.tgz
		-> ${P}-npm-dd2d1e1450fb9096f454.tgz
	${NPM_REGISTRY_URI}/is-async-function/-/is-async-function-2.1.1.tgz
		-> ${P}-npm-7b899987537cdb5007fe.tgz
	${NPM_REGISTRY_URI}/is-bigint/-/is-bigint-1.1.0.tgz
		-> ${P}-npm-7941a5461295a0ceaf0b.tgz
	${NPM_REGISTRY_URI}/is-binary-path/-/is-binary-path-2.1.0.tgz
		-> ${P}-npm-443535fb8cb143a477f5.tgz
	${NPM_REGISTRY_URI}/is-boolean-object/-/is-boolean-object-1.2.2.tgz
		-> ${P}-npm-b11274c4ab3b02a855ab.tgz
	${NPM_REGISTRY_URI}/is-callable/-/is-callable-1.2.7.tgz
		-> ${P}-npm-7cd4d0c373ab5f91c75f.tgz
	${NPM_REGISTRY_URI}/is-core-module/-/is-core-module-2.16.2.tgz
		-> ${P}-npm-8a8bb4fcb198182af6f1.tgz
	${NPM_REGISTRY_URI}/is-data-view/-/is-data-view-1.0.2.tgz
		-> ${P}-npm-58c7bc9c5ab583a508aa.tgz
	${NPM_REGISTRY_URI}/is-date-object/-/is-date-object-1.1.0.tgz
		-> ${P}-npm-b5d2dfa167d4e958364e.tgz
	${NPM_REGISTRY_URI}/is-document.all/-/is-document.all-1.0.0.tgz
		-> ${P}-npm-7b1a32aa4d9b98523d5d.tgz
	${NPM_REGISTRY_URI}/is-extglob/-/is-extglob-2.1.1.tgz
		-> ${P}-npm-f3bb75392d5057a5b86c.tgz
	${NPM_REGISTRY_URI}/is-finalizationregistry/-/is-finalizationregistry-1.1.1.tgz
		-> ${P}-npm-9d0736a298780db2c067.tgz
	${NPM_REGISTRY_URI}/is-generator-function/-/is-generator-function-1.1.2.tgz
		-> ${P}-npm-da9efeb900abbd5bbbf3.tgz
	${NPM_REGISTRY_URI}/is-glob/-/is-glob-4.0.3.tgz
		-> ${P}-npm-20086cdd9509b3b0de97.tgz
	${NPM_REGISTRY_URI}/is-map/-/is-map-2.0.3.tgz
		-> ${P}-npm-f03a63f61d771cdef083.tgz
	${NPM_REGISTRY_URI}/is-negative-zero/-/is-negative-zero-2.0.3.tgz
		-> ${P}-npm-323b50ee9f8469b4f412.tgz
	${NPM_REGISTRY_URI}/is-number-object/-/is-number-object-1.1.1.tgz
		-> ${P}-npm-3d2da65d451edb401740.tgz
	${NPM_REGISTRY_URI}/is-number/-/is-number-7.0.0.tgz
		-> ${P}-npm-cc0d58ecfce55b065ea8.tgz
	${NPM_REGISTRY_URI}/is-regex/-/is-regex-1.2.1.tgz
		-> ${P}-npm-38a010cd95990c694d38.tgz
	${NPM_REGISTRY_URI}/is-set/-/is-set-2.0.3.tgz
		-> ${P}-npm-9d3d70bcb03ef0d1c988.tgz
	${NPM_REGISTRY_URI}/is-shared-array-buffer/-/is-shared-array-buffer-1.0.4.tgz
		-> ${P}-npm-cd9479e378076e3f3035.tgz
	${NPM_REGISTRY_URI}/is-string/-/is-string-1.1.1.tgz
		-> ${P}-npm-bf9cd39664db72ab2195.tgz
	${NPM_REGISTRY_URI}/is-symbol/-/is-symbol-1.1.1.tgz
		-> ${P}-npm-d6ed705e51bb874c9ec3.tgz
	${NPM_REGISTRY_URI}/is-typed-array/-/is-typed-array-1.1.15.tgz
		-> ${P}-npm-0943dd15c789917b8b34.tgz
	${NPM_REGISTRY_URI}/is-weakmap/-/is-weakmap-2.0.2.tgz
		-> ${P}-npm-a87a387232d81bdd1427.tgz
	${NPM_REGISTRY_URI}/is-weakref/-/is-weakref-1.1.1.tgz
		-> ${P}-npm-a5e652e3eba14d7a74a6.tgz
	${NPM_REGISTRY_URI}/is-weakset/-/is-weakset-2.0.4.tgz
		-> ${P}-npm-feb44518b72bf43373e6.tgz
	${NPM_REGISTRY_URI}/isarray/-/isarray-2.0.5.tgz
		-> ${P}-npm-dc3c987d484e7276a341.tgz
	${NPM_REGISTRY_URI}/isexe/-/isexe-2.0.0.tgz
		-> ${P}-npm-196757ee5bcda0ae690c.tgz
	${NPM_REGISTRY_URI}/json-parse-better-errors/-/json-parse-better-errors-1.0.2.tgz
		-> ${P}-npm-0c4ae90c4b5b005d7fa6.tgz
	${NPM_REGISTRY_URI}/load-json-file/-/load-json-file-4.0.0.tgz
		-> ${P}-npm-e926f9f530b37f49af1b.tgz
	${NPM_REGISTRY_URI}/math-intrinsics/-/math-intrinsics-1.1.0.tgz
		-> ${P}-npm-65f1b46c600f005d7005.tgz
	${NPM_REGISTRY_URI}/memorystream/-/memorystream-0.3.1.tgz
		-> ${P}-npm-8758b32dbb482885010d.tgz
	${NPM_REGISTRY_URI}/minimatch/-/minimatch-3.1.5.tgz
		-> ${P}-npm-3d86972e665a2ed34286.tgz
	${NPM_REGISTRY_URI}/ms/-/ms-2.1.3.tgz
		-> ${P}-npm-7f1f904879825b70e538.tgz
	${NPM_REGISTRY_URI}/nice-try/-/nice-try-1.0.5.tgz
		-> ${P}-npm-00ccf7924483f951f252.tgz
	${NPM_REGISTRY_URI}/nodemon/-/nodemon-3.1.10.tgz
		-> ${P}-npm-9633d19f762f3e5ac9a3.tgz
	${NPM_REGISTRY_URI}/normalize-package-data/-/normalize-package-data-2.5.0.tgz
		-> ${P}-npm-06d75a9f2d46221b54c7.tgz
	${NPM_REGISTRY_URI}/normalize-path/-/normalize-path-3.0.0.tgz
		-> ${P}-npm-df07031725d01d818b97.tgz
	${NPM_REGISTRY_URI}/npm-run-all/-/npm-run-all-4.1.5.tgz
		-> ${P}-npm-75c06f2878a0df345abf.tgz
	${NPM_REGISTRY_URI}/object-inspect/-/object-inspect-1.13.4.tgz
		-> ${P}-npm-636f8f44fb48c0871a4d.tgz
	${NPM_REGISTRY_URI}/object-keys/-/object-keys-1.1.1.tgz
		-> ${P}-npm-a712176a765ddcf398b6.tgz
	${NPM_REGISTRY_URI}/object.assign/-/object.assign-4.1.7.tgz
		-> ${P}-npm-3040cf19dd88777068e6.tgz
	${NPM_REGISTRY_URI}/own-keys/-/own-keys-1.0.1.tgz
		-> ${P}-npm-1eac42508e0922c2e40c.tgz
	${NPM_REGISTRY_URI}/parse-json/-/parse-json-4.0.0.tgz
		-> ${P}-npm-a1e7de6dcc3e5b0f071e.tgz
	${NPM_REGISTRY_URI}/path-key/-/path-key-2.0.1.tgz
		-> ${P}-npm-c1e07c0e9d59160dd8aa.tgz
	${NPM_REGISTRY_URI}/path-parse/-/path-parse-1.0.7.tgz
		-> ${P}-npm-9f13fd4b6f858c06f212.tgz
	${NPM_REGISTRY_URI}/path-type/-/path-type-3.0.0.tgz
		-> ${P}-npm-78312f0b0c4ee480a953.tgz
	${NPM_REGISTRY_URI}/picomatch/-/picomatch-2.3.2.tgz
		-> ${P}-npm-52244350e6a7cab5116b.tgz
	${NPM_REGISTRY_URI}/pidtree/-/pidtree-0.3.1.tgz
		-> ${P}-npm-61244407122d480a5102.tgz
	${NPM_REGISTRY_URI}/pify/-/pify-3.0.0.tgz
		-> ${P}-npm-31cc4b9709f2960caa1e.tgz
	${NPM_REGISTRY_URI}/possible-typed-array-names/-/possible-typed-array-names-1.1.0.tgz
		-> ${P}-npm-e63e46e168ef8f94649d.tgz
	${NPM_REGISTRY_URI}/pstree.remy/-/pstree.remy-1.1.8.tgz
		-> ${P}-npm-2afa5a18461d5ffca005.tgz
	${NPM_REGISTRY_URI}/react-reconciler/-/react-reconciler-0.32.0.tgz
		-> ${P}-npm-21df1729e12558a034f5.tgz
	${NPM_REGISTRY_URI}/react/-/react-19.1.1.tgz
		-> ${P}-npm-03ae75f42a2d7fac7c59.tgz
	${NPM_REGISTRY_URI}/react/-/react-19.2.7.tgz
		-> ${P}-npm-d2e83e5b4b1e5a8a88f3.tgz
	${NPM_REGISTRY_URI}/read-pkg/-/read-pkg-3.0.0.tgz
		-> ${P}-npm-bd765d2d414902f847fc.tgz
	${NPM_REGISTRY_URI}/readdirp/-/readdirp-3.6.0.tgz
		-> ${P}-npm-c2ae67e1facf31ad5db3.tgz
	${NPM_REGISTRY_URI}/readdirp/-/readdirp-4.1.2.tgz
		-> ${P}-npm-3e412b1535d574473797.tgz
	${NPM_REGISTRY_URI}/reflect.getprototypeof/-/reflect.getprototypeof-1.0.10.tgz
		-> ${P}-npm-deabc134826449b44cfd.tgz
	${NPM_REGISTRY_URI}/regexp.prototype.flags/-/regexp.prototype.flags-1.5.4.tgz
		-> ${P}-npm-9e0ec80f930cf33cf228.tgz
	${NPM_REGISTRY_URI}/resolve/-/resolve-1.22.12.tgz
		-> ${P}-npm-36e6f13e9211ea02bf0d.tgz
	${NPM_REGISTRY_URI}/safe-array-concat/-/safe-array-concat-1.1.4.tgz
		-> ${P}-npm-10badbb7cf8767c1365e.tgz
	${NPM_REGISTRY_URI}/safe-push-apply/-/safe-push-apply-1.0.0.tgz
		-> ${P}-npm-6c69857c9c572d855542.tgz
	${NPM_REGISTRY_URI}/safe-regex-test/-/safe-regex-test-1.1.0.tgz
		-> ${P}-npm-439f35e68fbcc131e984.tgz
	${NPM_REGISTRY_URI}/scheduler/-/scheduler-0.26.0.tgz
		-> ${P}-npm-d90295519b7547d2593a.tgz
	${NPM_REGISTRY_URI}/semver/-/semver-5.7.2.tgz
		-> ${P}-npm-efceb9eb7225dfe81818.tgz
	${NPM_REGISTRY_URI}/semver/-/semver-7.8.5.tgz
		-> ${P}-npm-98048b77ecadcb357f14.tgz
	${NPM_REGISTRY_URI}/set-function-length/-/set-function-length-1.2.2.tgz
		-> ${P}-npm-154e71457695092ef25b.tgz
	${NPM_REGISTRY_URI}/set-function-name/-/set-function-name-2.0.2.tgz
		-> ${P}-npm-a924e42e3d160d6c137d.tgz
	${NPM_REGISTRY_URI}/set-proto/-/set-proto-1.0.0.tgz
		-> ${P}-npm-3e3847482dc09da6c228.tgz
	${NPM_REGISTRY_URI}/shebang-command/-/shebang-command-1.2.0.tgz
		-> ${P}-npm-a2826fe8d61d9deb5019.tgz
	${NPM_REGISTRY_URI}/shebang-regex/-/shebang-regex-1.0.0.tgz
		-> ${P}-npm-58c451c81400e8cd33b1.tgz
	${NPM_REGISTRY_URI}/shell-quote/-/shell-quote-1.9.0.tgz
		-> ${P}-npm-9d08ed98feb2fac85abc.tgz
	${NPM_REGISTRY_URI}/side-channel-list/-/side-channel-list-1.0.1.tgz
		-> ${P}-npm-2b565d463ed1ca9b3a3b.tgz
	${NPM_REGISTRY_URI}/side-channel-map/-/side-channel-map-1.0.1.tgz
		-> ${P}-npm-b255b72625085d5d4c44.tgz
	${NPM_REGISTRY_URI}/side-channel-weakmap/-/side-channel-weakmap-1.0.2.tgz
		-> ${P}-npm-e043c2b4910c8d8d295b.tgz
	${NPM_REGISTRY_URI}/side-channel/-/side-channel-1.1.1.tgz
		-> ${P}-npm-7cdadb77905522544408.tgz
	${NPM_REGISTRY_URI}/simple-update-notifier/-/simple-update-notifier-2.0.0.tgz
		-> ${P}-npm-c822af38d8df3d8cf0b3.tgz
	${NPM_REGISTRY_URI}/spdx-correct/-/spdx-correct-3.2.0.tgz
		-> ${P}-npm-6be5bdf1b5aeb8b490de.tgz
	${NPM_REGISTRY_URI}/spdx-exceptions/-/spdx-exceptions-2.5.0.tgz
		-> ${P}-npm-11e85bb5d8fc9fd2e761.tgz
	${NPM_REGISTRY_URI}/spdx-expression-parse/-/spdx-expression-parse-3.0.1.tgz
		-> ${P}-npm-f7503865577c3206d087.tgz
	${NPM_REGISTRY_URI}/spdx-license-ids/-/spdx-license-ids-3.0.23.tgz
		-> ${P}-npm-113ed8574a49cd132909.tgz
	${NPM_REGISTRY_URI}/stop-iteration-iterator/-/stop-iteration-iterator-1.1.0.tgz
		-> ${P}-npm-7db69a73f22acf0f5fb8.tgz
	${NPM_REGISTRY_URI}/string.prototype.padend/-/string.prototype.padend-3.1.6.tgz
		-> ${P}-npm-eb8696fde33f5986cc9b.tgz
	${NPM_REGISTRY_URI}/string.prototype.trim/-/string.prototype.trim-1.2.11.tgz
		-> ${P}-npm-65d9080aa6b2fd60317b.tgz
	${NPM_REGISTRY_URI}/string.prototype.trimend/-/string.prototype.trimend-1.0.10.tgz
		-> ${P}-npm-1fc9dd02bcc5d7d12821.tgz
	${NPM_REGISTRY_URI}/string.prototype.trimstart/-/string.prototype.trimstart-1.0.8.tgz
		-> ${P}-npm-ea032fcef93c5f75240b.tgz
	${NPM_REGISTRY_URI}/strip-bom/-/strip-bom-3.0.0.tgz
		-> ${P}-npm-8718b3ce2bb46e861f61.tgz
	${NPM_REGISTRY_URI}/supports-color/-/supports-color-5.5.0.tgz
		-> ${P}-npm-185205cf34138b24a45e.tgz
	${NPM_REGISTRY_URI}/supports-preserve-symlinks-flag/-/supports-preserve-symlinks-flag-1.0.0.tgz
		-> ${P}-npm-2f6952617f0407047b98.tgz
	${NPM_REGISTRY_URI}/to-regex-range/-/to-regex-range-5.0.1.tgz
		-> ${P}-npm-f9e0119859209c62f539.tgz
	${NPM_REGISTRY_URI}/touch/-/touch-3.1.1.tgz
		-> ${P}-npm-c9ccbffeede1b29dbb0b.tgz
	${NPM_REGISTRY_URI}/typed-array-buffer/-/typed-array-buffer-1.0.3.tgz
		-> ${P}-npm-e76388d10737ee5aa8e3.tgz
	${NPM_REGISTRY_URI}/typed-array-byte-length/-/typed-array-byte-length-1.0.3.tgz
		-> ${P}-npm-49b60b56de36c50069ca.tgz
	${NPM_REGISTRY_URI}/typed-array-byte-offset/-/typed-array-byte-offset-1.0.4.tgz
		-> ${P}-npm-6b8a76f896ee29733609.tgz
	${NPM_REGISTRY_URI}/typed-array-length/-/typed-array-length-1.0.8.tgz
		-> ${P}-npm-8c2dc136cfbb6534d507.tgz
	${NPM_REGISTRY_URI}/typescript/-/typescript-5.9.2.tgz
		-> ${P}-npm-a8a920d48b7486d316df.tgz
	${NPM_REGISTRY_URI}/unbox-primitive/-/unbox-primitive-1.1.0.tgz
		-> ${P}-npm-3064cdf6cd65e8e1791e.tgz
	${NPM_REGISTRY_URI}/undefsafe/-/undefsafe-2.0.5.tgz
		-> ${P}-npm-e978fdb05ffa0ce9bdfc.tgz
	${NPM_REGISTRY_URI}/undici-types/-/undici-types-6.21.0.tgz
		-> ${P}-npm-74746a78e6d7b049a3ab.tgz
	${NPM_REGISTRY_URI}/undici-types/-/undici-types-7.10.0.tgz
		-> ${P}-npm-078cb1fc9c2b9d6cc6f1.tgz
	${NPM_REGISTRY_URI}/validate-npm-package-license/-/validate-npm-package-license-3.0.4.tgz
		-> ${P}-npm-b59e37abaa74ad5f5eb7.tgz
	${NPM_REGISTRY_URI}/which-boxed-primitive/-/which-boxed-primitive-1.1.1.tgz
		-> ${P}-npm-8303e7905cdb50de9d22.tgz
	${NPM_REGISTRY_URI}/which-builtin-type/-/which-builtin-type-1.2.1.tgz
		-> ${P}-npm-8fb567ff6e1b5ca41a78.tgz
	${NPM_REGISTRY_URI}/which-collection/-/which-collection-1.0.2.tgz
		-> ${P}-npm-6fa276b5f4a3e3cfb051.tgz
	${NPM_REGISTRY_URI}/which-typed-array/-/which-typed-array-1.1.22.tgz
		-> ${P}-npm-9766eded13ec7334018a.tgz
	${NPM_REGISTRY_URI}/which/-/which-1.3.1.tgz
		-> ${P}-npm-3353ed507040c5ab035d.tgz
	${NPM_REGISTRY_URI}/zod/-/zod-4.4.3.tgz
		-> ${P}-npm-5e69e6770447e1e0282f.tgz
"
SRC_URI+="
	typescript-extensions? ( ${NPM_SRC_URI} )"

S="${WORKDIR}/${P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="abi_x86_x32 typescript-extensions"
REQUIRED_USE="typescript-extensions? ( !abi_x86_x32 )"

BDEPEND="
	dev-build/cmake
	dev-build/ninja
	dev-libs/wayland-protocols
	dev-qt/qttools:6[linguist]
	dev-util/wayland-scanner
	sys-devel/gettext
	virtual/pkgconfig
	typescript-extensions? ( !abi_x86_x32? ( net-libs/nodejs[npm] ) )
"

DEPEND="
	app-text/cmark-gfm
	>=dev-cpp/glaze-7.2.0
	dev-libs/qtkeychain
	dev-libs/wayland
	dev-qt/qtbase:6[dbus,gui,network]
	dev-qt/qtdeclarative:6
	dev-qt/qtshadertools:6
	dev-qt/qtsvg:6
	dev-qt/qtwayland:6
	kde-frameworks/syntax-highlighting
	kde-plasma/layer-shell-qt
	sci-libs/libqalculate
	virtual/libudev
	x11-libs/libxkbcommon[wayland]
	dev-libs/openssl
"

RDEPEND="
	app-text/cmark-gfm
	dev-libs/qtkeychain
	dev-libs/wayland
	dev-qt/qtbase:6[dbus,gui,network]
	dev-qt/qtdeclarative:6
	dev-qt/qtshadertools:6
	dev-qt/qtsvg:6
	dev-qt/qtwayland:6
	kde-frameworks/syntax-highlighting
	kde-plasma/layer-shell-qt
	sci-libs/libqalculate
	virtual/libudev
	x11-libs/libxkbcommon[wayland]
	dev-libs/openssl
	typescript-extensions? ( !abi_x86_x32? ( net-libs/nodejs ) )
"

PATCHES=(
	"${FILESDIR}/${P}-wayland-only.patch"
	"${FILESDIR}/${P}-destdir-install.patch"
)

src_prepare() {
	cmake_src_prepare

	if use typescript-extensions; then
		local distfile module
		export npm_config_cache="${T}/npm-cache"
		export npm_config_offline=true

		for distfile in ${NPM_DISTFILES}; do
			npm --cache "${npm_config_cache}" --offline cache add "${DISTDIR}/${distfile}" || die
		done

		for module in api extension-manager; do
			einfo "Installing locked npm dependencies for ${module} from the Portage cache"
			(cd "src/typescript/${module}" && npm ci --offline --no-audit --no-fund) || die
		done
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DVICINAE_GIT_TAG="v${PV}"
		-DVICINAE_GIT_COMMIT_HASH="4e7af129ca89fbb6574c8409a4d32ad468c7161d"
		-DVICINAE_PROVENANCE=ebuild
		-DUSE_SYSTEM_CMARK_GFM=ON
		-DUSE_SYSTEM_GLAZE=ON
		-DUSE_SYSTEM_KF6=ON
		-DUSE_SYSTEM_LAYER_SHELL=ON
		-DUSE_SYSTEM_NUMEN=OFF
		-DUSE_SYSTEM_QT_KEYCHAIN=ON
		-DUSE_PRECOMPILED_HEADERS=OFF
		-DWAYLAND_LAYER_SHELL=ON
		-DTYPESCRIPT_EXTENSIONS="$(usex typescript-extensions ON OFF)"
		-DINSTALL_NODE_MODULES=OFF
		-DVICINAE_NODE_RUNTIME_DOWNLOAD=OFF
		-DAUTO_ENABLE_AUTOSTART=OFF
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_NUMEN="${WORKDIR}/numen-0.8.1"
	)

	cmake_src_configure
}
