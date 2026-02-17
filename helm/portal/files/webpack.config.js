const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');
const fs = require('fs');
const basename = process.env.BASENAME || '/';
const basenameWithTrailingSlash = basename.endsWith('/') ? basename : `${basename}/`;
const pathPrefix = basename.endsWith('/') ? basename.slice(0, basename.length - 1) : basename;
const app = process.env.APP || 'dev';
const BUILD_OUTDIR = process.env.WEBPACK_OUTDIR ? path.resolve(process.env.WEBPACK_OUTDIR) : path.resolve(__dirname, 'dist');
const WEBPACK_CACHE_DIR = process.env.WEBPACK_CACHE_DIR ? path.resolve(process.env.WEBPACK_CACHE_DIR) : path.join(BUILD_OUTDIR, '.webpack-cache');
const configFileName = (app === 'dev') ? 'default' : app;
const configFile = require(`./data/config/${configFileName}.json`);
const DISABLE_CACHE = '1';
const { DAPTrackingURL, gaTrackingId } = configFile;
const scriptSrcURLs = []; const connectSrcURLs = []; const imgSrcURLs = [];
if (DAPTrackingURL) { scriptSrcURLs.push(DAPTrackingURL); connectSrcURLs.push(DAPTrackingURL); }
if (gaTrackingId?.startsWith('UA-') || gaTrackingId?.startsWith('G-')) {
  scriptSrcURLs.push(...['https://www.google-analytics.com','https://ssl.google-analytics.com','https://www.googletagmanager.com']);
  connectSrcURLs.push(...['https://www.google-analytics.com','https://*.analytics.google.com','https://analytics.google.com','https://*.g.doubleclick.net']);
  imgSrcURLs.push('https://www.google-analytics.com','https://*.g.doubleclick.net','https://*.google.com');
} else { console.log('Unknown GA tag, skipping GA setup...'); }
if (process.env.DATA_UPLOAD_BUCKET) { connectSrcURLs.push(`https://${process.env.DATA_UPLOAD_BUCKET}.s3.amazonaws.com`); }
if (configFile.connectSrcCSPWhitelist && configFile.connectSrcCSPWhitelist.length > 0) { connectSrcURLs.push(...configFile.connectSrcCSPWhitelist); }
if (configFile.featureFlags?.discoveryUseAggMDS) { connectSrcURLs.push('https://dataguids.org'); }
if (configFile.featureFlags?.studyRegistration) { connectSrcURLs.push('https://clinicaltrials.gov'); }
if (process.env.DATADOG_APPLICATION_ID && process.env.DATADOG_CLIENT_TOKEN) {
  connectSrcURLs.push('https://*.logs.datadoghq.com','https://*.browser-intake-ddog-gov.com');
}
if (configFile.grafanaFaroConfig?.grafanaFaroEnable) {
  if (configFile.grafanaFaroConfig?.grafanaFaroUrl) connectSrcURLs.push(configFile.grafanaFaroConfig.grafanaFaroUrl);
  else connectSrcURLs.push('https://faro.planx-pla.net');
}
if (process.env.MAPBOX_API_TOKEN) {
  connectSrcURLs.push('https://*.tiles.mapbox.com','https://api.mapbox.com','https://events.mapbox.com');
}
const iFrameApplicationURLs = [];
if (configFile?.analysisTools) { configFile.analysisTools.forEach((e)=>{ if (e.applicationUrl) iFrameApplicationURLs.push(e.applicationUrl); }); }
function getCSSVersion() {
  const overridesCss = './src/css/themeoverrides.css';
  if (!fs.existsSync(overridesCss)) { console.warn(`${overridesCss} does not exist`); return (''); }
  const stats = fs.statSync(overridesCss); return (stats.mtime.getTime());
}
const plugins = [
  new webpack.EnvironmentPlugin(['NODE_ENV']),
  new webpack.EnvironmentPlugin({ MOCK_STORE: null }),
  new webpack.EnvironmentPlugin(['APP']),
  new webpack.EnvironmentPlugin({ BASENAME: '/' }),
  new webpack.EnvironmentPlugin(['LOGOUT_INACTIVE_USERS']),
  new webpack.EnvironmentPlugin(['WORKSPACE_TIMEOUT_IN_MINUTES']),
  new webpack.EnvironmentPlugin(['REACT_APP_PROJECT_ID']),
  new webpack.EnvironmentPlugin(['REACT_APP_DISABLE_SOCKET']),
  new webpack.EnvironmentPlugin(['TIER_ACCESS_LEVEL']),
  new webpack.EnvironmentPlugin(['TIER_ACCESS_LIMIT']),
  new webpack.EnvironmentPlugin(['FENCE_URL']),
  new webpack.EnvironmentPlugin(['INDEXD_URL']),
  new webpack.EnvironmentPlugin(['USE_INDEXD_AUTHZ']),
  new webpack.EnvironmentPlugin(['WORKSPACE_URL']),
  new webpack.EnvironmentPlugin(['WTS_URL']),
  new webpack.EnvironmentPlugin(['MANIFEST_SERVICE_URL']),
  new webpack.EnvironmentPlugin(['MAPBOX_API_TOKEN']),
  new webpack.EnvironmentPlugin(['DATADOG_APPLICATION_ID']),
  new webpack.EnvironmentPlugin(['DATADOG_CLIENT_TOKEN']),
  new webpack.EnvironmentPlugin(['DATA_UPLOAD_BUCKET']),
  new webpack.EnvironmentPlugin(['GEN3_BUNDLE']),
  new HtmlWebpackPlugin({
    title: configFile.components.appName || 'Generic Data Commons',
    metaDescription: configFile.components.metaDescription || '',
    basename: pathPrefix,
    cssVersion: getCSSVersion(),
    template: 'src/index.ejs',
    filename: 'index.html',
    connectSrc: ((() => {
      const rv = {};
      const push = u => { try { rv[(new URL(u)).origin] = true; } catch(e){} };
      ['FENCE_URL','INDEXD_URL','WORKSPACE_URL','WTS_URL','MANIFEST_SERVICE_URL']
        .forEach(k => { if (process.env[k]) push(process.env[k]); });
      iFrameApplicationURLs.forEach(u => push(u));
      connectSrcURLs.forEach(u => push(u));
      return Object.keys(rv).join(' ');
    })()),
    scriptSrc: ((() => {
      const rv = {}; const push = u => { try { rv[(new URL(u)).origin] = true; } catch(e){} };
      scriptSrcURLs.forEach(u => push(u));
      return Object.keys(rv).join(' ');
    })()),
    imgSrc: ((() => {
      const rv = {}; const push = u => { try { rv[(new URL(u)).origin] = true; } catch(e){} };
      imgSrcURLs.forEach(u => push(u));
      return Object.keys(rv).join(' ');
    })()),
    dapURL: DAPTrackingURL,
    hash: true,
    chunks: ['vendors~bundle','bundle'],
  }),
  new webpack.optimize.AggressiveMergingPlugin(),
];
const allowedHosts = process.env.HOSTNAME ? [process.env.HOSTNAME] : 'auto';
let optimization = {}; let devtool = false;
if (process.env.NODE_ENV !== 'dev' && process.env.NODE_ENV !== 'auto') { optimization = { splitChunks: { chunks: 'all' } }; }
else { devtool = 'eval-source-map'; }
const entry = {
  bundle: './src/index.jsx',
  workspaceBundle: './src/workspaceIndex.jsx',
  covid19Bundle: './src/covid19Index.jsx',
  nctBundle: './src/nctIndex.jsx',
  ecosystemBundle: './src/ecosystemIndex.jsx',
};
if (process.env.GEN3_BUNDLE) {
  switch (process.env.GEN3_BUNDLE) {
    case 'workspace': entry.bundle = entry.workspaceBundle; delete entry.workspaceBundle; delete entry.covid19Bundle; delete entry.nctBundle; delete entry.ecosystemBundle; break;
    case 'covid19':   entry.bundle = entry.covid19Bundle;   delete entry.workspaceBundle; delete entry.covid19Bundle; delete entry.nctBundle; delete entry.ecosystemBundle; break;
    case 'nct':       entry.bundle = entry.nctBundle;       delete entry.workspaceBundle; delete entry.covid19Bundle; delete entry.nctBundle; delete entry.ecosystemBundle; break;
    case 'heal':
    case 'ecosystem': entry.bundle = entry.ecosystemBundle; delete entry.workspaceBundle; delete entry.covid19Bundle; delete entry.nctBundle; delete entry.ecosystemBundle; break;
    default:          delete entry.workspaceBundle; delete entry.covid19Bundle; delete entry.nctBundle; delete entry.ecosystemBundle;
  }
}
module.exports = {
  entry,
  target: 'web',
  externals: [{ xmlhttprequest: '{XMLHttpRequest:XMLHttpRequest}' }],
  mode: process.env.NODE_ENV !== 'dev' && process.env.NODE_ENV !== 'auto' ? 'production' : 'development',
  output: { path: BUILD_OUTDIR, filename: '[name].js', publicPath: basenameWithTrailingSlash },
  cache: false,
  optimization, devtool,
  module: {
    rules: [
      { test: /\.jsx?$|\.tsx?$/, exclude: /node_modules\/(?!(graphiql|graphql-language-service-parser)\/).*/,
        use: { loader: 'babel-loader', options: { presets: ['@babel/preset-env','@babel/react'], plugins: ['@babel/plugin-proposal-class-properties'], cacheDirectory: path.join(WEBPACK_CACHE_DIR,'babel'), cacheCompression: false } } },
      { test: /\.less$/, loaders: ['style-loader','css-loader','less-loader'] },
      { test: /\.css$/,  loader: 'style-loader!css-loader' },
      { test: /\.svg$/,  loader: 'svg-react-loader' },
      { test: /\.(png|jpg|gif|woff|ttf|eot)$/, loaders: 'url-loader', query: { limit: 8192 } },
      { test: /\.flow$/, loader: 'ignore-loader' },
    ],
  },
  resolve: {
    alias: {
      graphql: path.resolve('./node_modules/graphql'),
      react: path.resolve('./node_modules/react'),
      graphiql: path.resolve('./node_modules/graphiql'),
      'graphql-language-service-parser': path.resolve('./node_modules/graphql-language-service-parser'),
    },
    extensions: ['.mjs','.js','.jsx','.ts','.tsx','.json'],
  },
  plugins,
};