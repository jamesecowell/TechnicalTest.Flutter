import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/presentation/pages/offline_post_list_page.dart';
import 'package:flutter_tech_task/presentation/pages/post_list_page.dart';

class PostListTabPage extends ConsumerWidget {
  const PostListTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlinePostsState = ref.watch(offlinePostListViewModelProvider);
    final offlinePostCount = offlinePostsState.maybeWhen(
      data: (posts) => posts.length,
      orElse: () => 0,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.posts),
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.allPosts),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.offline),
                    if (offlinePostCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$offlinePostCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PostListPage(),
            OfflinePostListPage(),
          ],
        ),
      ),
    );
  }
}
