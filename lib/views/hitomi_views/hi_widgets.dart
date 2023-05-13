import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pica_comic/network/hitomi_network/hitomi_main_network.dart';
import 'package:pica_comic/network/hitomi_network/hitomi_models.dart';
import 'package:pica_comic/views/hitomi_views/hitomi_comic_page.dart';
import 'package:pica_comic/views/widgets/widgets.dart';
import 'package:get/get.dart';

class HiComicTile extends StatelessWidget {
  final HitomiComicBrief comic;
  const HiComicTile(this.comic, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(()=>HitomiComicPage(comic)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16)
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      httpHeaders: const {
                        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36",
                        "Referer": "https://hitomi.la/"
                      },
                      imageUrl: comic.cover,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: double.infinity,
                    ),
                  )
              ),
              SizedBox.fromSize(size: const Size(16,5),),
              Expanded(
                flex: 7,
                child: ComicDescription(
                  title: comic.name,
                  user: comic.name,
                  subDescription: comic.time,
                ),
              ),
              //const Center(
              //  child: Icon(Icons.arrow_right),
              //)
            ],
          ),
        )
    );
  }
}

class ComicDescription extends StatelessWidget {
  const ComicDescription({super.key,
    required this.title,
    required this.user,
    required this.subDescription,
  });

  final String title;
  final String user;
  final String subDescription;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            user,
            style: const TextStyle(fontSize: 10.0),
            maxLines: 1,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  subDescription,
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HitomiComicTileDynamicLoading extends StatefulWidget {
  const HitomiComicTileDynamicLoading(this.id, {Key? key}) : super(key: key);
  final int id;

  @override
  State<HitomiComicTileDynamicLoading> createState() => _HitomiComicTileDynamicLoadingState();
}

class _HitomiComicTileDynamicLoadingState extends State<HitomiComicTileDynamicLoading> {
  HitomiComicBrief? comic;
  bool onScreen = true;

  static List<HitomiComicBrief> cache = [];

  @override
  void dispose() {
    onScreen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for(var cachedComic in cache){
      var id = RegExp(r"\d+(?=\.html)").firstMatch(cachedComic.link)![0]!;
      if(id == widget.id.toString()){
        comic = cachedComic;
      }
    }
    if(comic == null) {
      HiNetwork().getComicInfoBrief(widget.id.toString()).then((c){
        if(c.error){
          showMessage(context, c.errorMessage!);
          return;
        }
        cache.add(c.data);
        if(onScreen) {
          setState(() {
          comic = c.data;
        });
        }
      });
      return Center(
        child: SizedBox(
          width: 80,
          height: 40,
          child: Row(
            children: const [
              CircularProgressIndicator(),
              Spacer(),
              Text("加载中")
            ],
          ),
        ),
      );
    }else{
      return HiComicTile(comic!);
    }
  }
}
