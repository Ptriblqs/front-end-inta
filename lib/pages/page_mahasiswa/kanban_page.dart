import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Shared & Routes
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';

// Modular (file di folder yang sama)
import 'package:inta301/pages/page_mahasiswa/kanban_card.dart';
import 'package:inta301/pages/page_mahasiswa/kanban_controller.dart';
import 'package:inta301/pages/page_mahasiswa/kanban_modal.dart';

// Alias agar tidak konflik dengan MenuController Flutter
import 'package:inta301/controllers/menu_controller.dart' as myCtrl;

// pondasi kanban
import 'package:inta301/models/kanban_task.dart';

class KanbanPage extends GetView<myCtrl.MenuController> {
  final bool hasDosen;
  final KanbanController kanbanController = Get.put(KanbanController());

  KanbanPage({super.key, required this.hasDosen});

  @override
  Widget build(BuildContext context) {
    controller.setPage(myCtrl.PageType.kanban);

    // -------------------------------------------------------------------------
    // Jika BELUM punya dosen pembimbing
    // -------------------------------------------------------------------------
    if (!hasDosen) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "Papan Kanban",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, dangerColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.only(top: 100),
          child: Center(
            child: Text(
              "Belum memiliki dosen pembimbing.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF616161),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => _BottomNavBar(
            currentPage: controller.currentPage.value,
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Jika SUDAH punya dosen pembimbing → tampilkan Kanban
    // -------------------------------------------------------------------------
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Papan Kanban",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      //-----------------------------------------------------------------------
      // TABBAR
      //-----------------------------------------------------------------------
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: defaultMargin,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: blackColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: "To Do"),
                  Tab(text: "In Progress"),
                  Tab(text: "Done"),
                ],
              ),
            ),

            //-------------------------------------------------------------------
            // TAB CONTENT
            //-------------------------------------------------------------------
            Expanded(
              child: TabBarView(
                children: [
                  _buildKanbanColumn(kanbanController.todoTasks, "To Do"),
                  _buildKanbanColumn(
                      kanbanController.inProgressTasks, "In Progress"),
                  _buildKanbanColumn(kanbanController.doneTasks, "Done"),
                ],
              ),
            ),
          ],
        ),
      ),

      //-----------------------------------------------------------------------
      // FAB
      //-----------------------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: dangerColor,
        onPressed: () {
          showAddKanbanModal(context, kanbanController, "To Do");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar:
          Obx(() => _BottomNavBar(currentPage: controller.currentPage.value)),
    );
  }

  // ---------------------------------------------------------------------------
  // Build Column kanban
  // ---------------------------------------------------------------------------
  Widget _buildKanbanColumn(RxList<KanbanTask> tasks, String column) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            defaultMargin, 6, defaultMargin, 16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              showEditKanbanModal(
                context,
                kanbanController,
                tasks,
                index,
                column,
              );
            },
            child: KanbanCard(task: tasks[index]),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Bottom Navigation
// ============================================================================
class _BottomNavBar extends StatelessWidget {
  final myCtrl.PageType currentPage;

  const _BottomNavBar({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<myCtrl.MenuController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, dangerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home,
            label: "Beranda",
            isActive: currentPage == myCtrl.PageType.home,
            onTap: () {
              controller.setPage(myCtrl.PageType.home);
              Get.offAllNamed(Routes.home);
            },
          ),
          _BottomNavItem(
            icon: Icons.calendar_month,
            label: "Jadwal",
            isActive: currentPage == myCtrl.PageType.jadwal,
            onTap: () {
              controller.setPage(myCtrl.PageType.jadwal);
              Get.offAllNamed(Routes.JADWAL);
            },
          ),
          _BottomNavItem(
            icon: Icons.bar_chart_outlined,
            label: "Kanban",
            isActive: currentPage == myCtrl.PageType.kanban,
            onTap: () {
              controller.setPage(myCtrl.PageType.kanban);
              Get.offAllNamed(Routes.KANBAN);
            },
          ),
          _BottomNavItem(
            icon: Icons.description_outlined,
            label: "Dokumen",
            isActive: currentPage == myCtrl.PageType.dokumen,
            onTap: () {
              controller.setPage(myCtrl.PageType.dokumen);
              Get.offAllNamed(Routes.DOKUMEN);
            },
          ),
          _BottomNavItem(
            icon: Icons.person_outline,
            label: "Profile",
            isActive: currentPage == myCtrl.PageType.profile,
            onTap: () {
              controller.setPage(myCtrl.PageType.profile);
              Get.offAllNamed(Routes.PROFILE);
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Bottom Navigation Item
// ============================================================================
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? Colors.yellow : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}