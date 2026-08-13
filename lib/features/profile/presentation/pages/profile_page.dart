import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() করলে যখনই profileNotifierProvider-এর state বদলাবে
    // (loading → data অথবা loading → error), এই widget automatically
    // rebuild হবে — আলাদা করে setState() লাগবে না।
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল')),
      body: RefreshIndicator(
        // নিচে টান দিলে notifier-এর refresh() method call হবে,
        // যেটা আবার নতুন করে GET call করবে।
        onRefresh: () => ref.read(profileNotifierProvider.notifier).refresh(),
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                // error object আসলে আমাদের Failure ক্লাসেরই একটা instance
                // (ProfileNotifier-এ আমরা `throw failure` করেছিলাম) —
                // তাই এখানে Failure হলে তার message দেখানো হচ্ছে।
                child: Text(
                  error is Failure ? error.message : 'কিছু একটা ভুল হয়েছে',
                ),
              ),
            ],
          ),
          data: (profile) {
            final user = profile.user; // nested user object — null হতে পারে
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user?.avatar != null
                      ? NetworkImage(user!.avatar.toString())
                      : null,
                  child: user?.avatar == null ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'নাম নেই', style: Theme.of(context).textTheme.titleLarge),
                Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                if (user?.phone != null) Text(user!.phone!),
                const SizedBox(height: 24),

                // backend থেকে পাওয়া stats — total_properties,
                // total_favorites, total_views — এগুলো ড্যাশবোর্ডের
                // মতো তিনটা কার্ডে দেখানো হচ্ছে।
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(label: 'Properties', value: profile.totalProperties ?? 0),
                    _StatCard(label: 'Favorites', value: profile.totalFavorites ?? 0),
                    _StatCard(label: 'Views', value: profile.totalViews ?? 0),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ছোট একটা reusable stat card widget — main page-কে ছোট রাখতে
/// আলাদা করে বের করা হয়েছে।
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
