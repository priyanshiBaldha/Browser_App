import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homepage(),
    ),
  );
}

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  List myBookMark = [];

  late InAppWebViewController inAppWebViewController;
  late PullToRefreshController pullToRefreshController;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();

  double progressVal = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: Colors.blueGrey),
        onRefresh: () async {
          await inAppWebViewController.reload();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Google'),
        actions: [
          IconButton(
            onPressed: () {
              inAppWebViewController.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse('https://www.google.com/'),
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.goBack();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.reload();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.goForward();
            },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      body: Column(
        children: [
          (progressVal < 1) ? SizedBox(
            height: 5,
            child: LinearProgressIndicator(
              value: progressVal,
              color: Colors.green,
              backgroundColor: Colors.grey,
            ),
          ) :const SizedBox(),
          Expanded(
            child: InAppWebView(
              initialOptions: InAppWebViewGroupOptions(
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  ),),
              pullToRefreshController: pullToRefreshController,

              onProgressChanged: (controller, index){
                setState(() {
                  progressVal = index/100;
                });
              },
              initialUrlRequest:
              URLRequest(url: Uri.parse('https://www.google.com/')),
              onWebViewCreated: (val) {
                setState(() {
                  inAppWebViewController = val;
                });
              },
              onLoadStop: (controller, uri) async {
                await pullToRefreshController.endRefreshing();
              },
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Center(child: Text('Search Bar')),
                    content: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Enter Here ...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.black)),
                            ),
                            controller: searchController,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Enter Here First!!!';
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                String keyword = searchController.text;

                                Uri uri = Uri.parse(
                                    'https://www.google.com/search?q=$keyword');
                                Navigator.pop(context);

                                inAppWebViewController.loadUrl(
                                    urlRequest: URLRequest(url: uri));
                              }
                            },
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.search),
          ),
          FloatingActionButton(
            onPressed: () async {
              Uri? uri = await inAppWebViewController.getUrl();

              myBookMark.add(uri.toString());
            },
            child: const Icon(Icons.bookmark_border),
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: const Center(
                      child: Text('BookMark List'),
                    ),
                    content: SizedBox(
                      height: 500,
                      width: 350,
                      child: ListView.builder(
                        itemCount: myBookMark.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.link_outlined),
                            title: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                inAppWebViewController.loadUrl(
                                  urlRequest: URLRequest(
                                    url: Uri.parse('${myBookMark[index]}'),
                                  ),
                                );
                              },
                              child: Text('${myBookMark[index]}'),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  myBookMark.remove(myBookMark[index]);
                                },
                                icon: const Icon(Icons.delete)),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.apps),
          ),
          FloatingActionButton(
            onPressed: () {
              inAppWebViewController.stopLoading();
            },
            child: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}