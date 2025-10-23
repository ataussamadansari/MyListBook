import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/list_model.dart';
import '../providers/lists_provider.dart';
import '../widgets/add_list_bottom_sheet.dart';
import 'list_items_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<DateTime> _getDateChips() {
    final now = DateTime.now();
    final List<DateTime> dates = [];

    // Get current week days (Sunday to Saturday)
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));

    for (int i = 0; i < 7; i++) {
      dates.add(currentWeekStart.add(Duration(days: i)));
    }

    return dates;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Book'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Consumer<ListsProvider>(
        builder: (context, provider, child) {
          final filteredLists = _selectedDate == null
              ? provider.lists
              : provider.lists.where((list) {
                  return list.updatedAt.year == _selectedDate!.year &&
                      list.updatedAt.month == _selectedDate!.month &&
                      list.updatedAt.day == _selectedDate!.day;
                }).toList();

          final totalLists = filteredLists.length;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Date Chips Sliver
              _buildDateChipsSliver(),

              // Statistics Sliver
              // _buildStatisticsSliver(provider, filteredLists, totalLists),

              // Charts Sliver
              // _buildChartsSliver(provider, filteredLists),

              // Lists Sliver
              _buildListsSliver(provider, filteredLists),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddListBottomSheet.show(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  SliverToBoxAdapter _buildDateChipsSliver() {
    final dateChips = _getDateChips();
    final selectedDate = _selectedDate ?? DateTime.now();

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            // Month and Year Display
            Container(
              padding: const EdgeInsets.only(bottom: 12, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.calendar_month, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedDate.day} ${_getMonthName(selectedDate)} ${selectedDate.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Date Chips Row
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...dateChips.map((date) {
                    final isSelected =
                        _selectedDate != null &&
                        _selectedDate!.year == date.year &&
                        _selectedDate!.month == date.month &&
                        _selectedDate!.day == date.day;

                    final isToday =
                        DateTime.now().year == date.year &&
                        DateTime.now().month == date.month &&
                        DateTime.now().day == date.day;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : isToday
                                ? Colors.blue.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : isToday
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isToday ? 1 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getDayName(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                      ? Colors.blue
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                        ? Colors.blue
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Custom Date Button
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'More',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
    );
  }

  SliverToBoxAdapter _buildStatisticsSliver(
    ListsProvider provider,
    List<GroceryList> filteredLists,
    int totalLists,
  ) {
    return SliverToBoxAdapter(
      child: FutureBuilder<double>(
        future: provider.getTotalCostForFilteredLists(filteredLists),
        builder: (context, snapshot) {
          final totalCost = snapshot.data ?? 0.0;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.list_alt,
                  value: totalLists.toString(),
                  label: 'Total Lists',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.attach_money,
                  value: '₹${totalCost.toStringAsFixed(2)}',
                  label: 'Total Cost',
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildChartsSliver(
    ListsProvider provider,
    List<GroceryList> filteredLists,
  ) {
    return SliverToBoxAdapter(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getChartData(provider, filteredLists),
        builder: (context, snapshot) {
          if (!snapshot.hasData || filteredLists.isEmpty) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No data available for charts',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          final chartData = snapshot.data!;
          final costData = chartData['costData'] as List<PieChartSectionData>;
          final barData = chartData['barData'] as List<BarChartGroupData>;

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Cost Distribution Pie Chart
                _buildPieChart(costData, 'Cost Distribution'),
                const SizedBox(height: 16),
                // Lists Bar Chart
                _buildBarChart(barData, 'Lists Overview'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(List<PieChartSectionData> sections, String title) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: sections,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> barGroups, String title) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '₹${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < barGroups.length) {
                            return SideTitleWidget(
                              meta: meta, // ✅ सही तरीका - meta pass करें
                              child: Text(
                                'L${index + 1}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '₹${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  barGroups: barGroups,
                  gridData: const FlGridData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barGroups.isEmpty
                      ? 100
                      : (barGroups
                                .map((e) => e.barRods.first.toY)
                                .reduce((a, b) => a > b ? a : b) *
                            1.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListsSliver(
    ListsProvider provider,
    List<GroceryList> filteredLists,
  ) {
    if (filteredLists.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _selectedDate == null
                    ? 'No grocery lists yet!'
                    : 'No lists on ${_getSelectedDateDisplay()}',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              Text(
                _selectedDate == null
                    ? 'Tap + to create your first list'
                    : 'Create a new list or select another date',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Last item के लिए padding add करें
          if (index == filteredLists.length) {
            return const SizedBox(height: 100); // FAB के लिए bottom padding
          }

          final list = filteredLists[index];
          return FutureBuilder<double>(
            future: provider.getListTotalCost(list.id!),
            builder: (context, snapshot) {
              final listCost = snapshot.data ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_cart, color: Colors.green),
                  ),
                  title: Text(
                    list.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.description.isNotEmpty
                            ? list.description
                            : 'No description',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cost: ₹${listCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(list.updatedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatTime(list.updatedAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    provider.setCurrentList(list);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListItemsScreen(),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showDeleteDialog(context, provider, list);
                  },
                ),
              );
            },
          );
        },
        childCount: filteredLists.length + 1, // ✅ +1 for padding
      ),
    );
  }

  /*Widget _buildListsSliver(
    ListsProvider provider,
    List<GroceryList> filteredLists,
  ) {
    if (filteredLists.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _selectedDate == null
                    ? 'No grocery lists yet!'
                    : 'No lists on ${_getSelectedDateDisplay()}',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              Text(
                _selectedDate == null
                    ? 'Tap + to create your first list'
                    : 'Create a new list or select another date',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final list = filteredLists[index];
        return FutureBuilder<double>(
          future: provider.getListTotalCost(list.id!),
          builder: (context, snapshot) {
            final listCost = snapshot.data ?? 0.0;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shopping_cart, color: Colors.green),
                ),
                title: Text(
                  list.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.description.isNotEmpty
                          ? list.description
                          : 'No description',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cost: ₹${listCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(list.updatedAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _formatTime(list.updatedAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  provider.setCurrentList(list);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListItemsScreen(),
                    ),
                  );
                },
                onLongPress: () {
                  _showDeleteDialog(context, provider, list);
                },
              ),
            );
          },
        );
      }, childCount: filteredLists.length),
    );
  }*/

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Future<Map<String, dynamic>> _getChartData(
    ListsProvider provider,
    List<GroceryList> filteredLists,
  ) async {
    final List<PieChartSectionData> pieSections = [];
    final List<BarChartGroupData> barGroups = [];

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    for (int i = 0; i < filteredLists.length && i < 5; i++) {
      final list = filteredLists[i];
      if (list.id != null) {
        final cost = await provider.getListTotalCost(list.id!);
        final isTouched = i == _touchedIndex;
        final fontSize = isTouched ? 16.0 : 12.0;
        final radius = isTouched ? 60.0 : 50.0;

        pieSections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: cost,
            title: '${cost.toInt()}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );

        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: cost,
                color: colors[i % colors.length],
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    }

    return {'costData': pieSections, 'barData': barGroups};
  }

  String _getSelectedDateDisplay() {
    if (_selectedDate == null) return 'All Dates';

    final now = DateTime.now();
    if (_selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day) {
      return 'Today • ${_formatFullDate(_selectedDate!)}';
    } else {
      return _formatFullDate(_selectedDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFullDate(DateTime date) {
    return '${date.day} ${_getMonthName(date)}, ${date.year}';
  }

  void _showDeleteDialog(
    BuildContext context,
    ListsProvider provider,
    GroceryList list,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete List'),
        content: Text(
          'Are you sure you want to delete "${list.title}"? This will also delete all items in the list.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            isDefaultAction: true,
            onPressed: () {
              provider.deleteList(list.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/list_model.dart';
import '../providers/lists_provider.dart';
import '../widgets/add_list_bottom_sheet.dart';
import 'list_items_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<DateTime> _getDateChips() {
    final now = DateTime.now();
    final List<DateTime> dates = [];

    // Get current week days (Sunday to Saturday)
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));

    for (int i = 0; i < 7; i++) {
      dates.add(currentWeekStart.add(Duration(days: i)));
    }

    return dates;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Lists'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ListsProvider>(
        builder: (context, provider, child) {
          final filteredLists = _selectedDate == null
              ? provider.lists
              : provider.lists.where((list) {
                  return list.updatedAt.year == _selectedDate!.year &&
                      list.updatedAt.month == _selectedDate!.month &&
                      list.updatedAt.day == _selectedDate!.day;
                }).toList();

          final totalLists = filteredLists.length;

          return Column(
            children: [
              // Date Chips Section (updated version)
              _buildDateChipsSection(),

              // Statistics Section with FutureBuilder for total cost
              FutureBuilder<double>(
                future: provider.getTotalCostForFilteredLists(filteredLists),
                builder: (context, snapshot) {
                  final totalCost = snapshot.data ?? 0.0;
                  return _buildStatisticsSection(totalLists, totalCost);
                },
              ),

              // Lists Section
              Expanded(child: _buildListsSection(provider, filteredLists)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddListBottomSheet.show(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateChipsSection() {
    final dateChips = _getDateChips();
    final selectedDate = _selectedDate ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.green),
      child: Column(
        children: [
          // Month and Year Display - TOP में integrated
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${selectedDate.day} ${_getMonthName(selectedDate)} ${selectedDate.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Date Chips Row
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...dateChips.map((date) {
                  final isSelected =
                      _selectedDate != null &&
                      _selectedDate!.year == date.year &&
                      _selectedDate!.month == date.month &&
                      _selectedDate!.day == date.day;

                  final isToday =
                      DateTime.now().year == date.year &&
                      DateTime.now().month == date.month &&
                      DateTime.now().day == date.day;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : isToday
                              ? Colors.blue.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : isToday
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: isToday ? 1 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getDayName(date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                      ? Colors.blue
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Custom Date Button
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'More',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(int totalLists, double totalCost) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.green.shade100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.list_alt,
            value: totalLists.toString(),
            label: 'Total Lists',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            value: '₹${totalCost.toStringAsFixed(2)}',
            label: 'Total Cost',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildListsSection(
    ListsProvider provider,
    List<GroceryList> filteredLists,
  ) {
    if (filteredLists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _selectedDate == null
                  ? 'No grocery lists yet!'
                  : 'No lists on ${_getSelectedDateDisplay()}',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            Text(
              _selectedDate == null
                  ? 'Tap + to create your first list'
                  : 'Create a new list or select another date',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredLists.length,
      itemBuilder: (context, index) {
        final list = filteredLists[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.green),
            title: Text(
              list.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              list.description.isNotEmpty ? list.description : 'No description',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(list.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _formatTime(list.updatedAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              provider.setCurrentList(list);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListItemsScreen(),
                ),
              );
            },
            onLongPress: () {
              _showDeleteDialog(context, provider, list);
            },
          ),
        );
      },
    );
  }

  String _getSelectedDateDisplay() {
    if (_selectedDate == null) return 'All Dates';

    final now = DateTime.now();
    if (_selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day) {
      return 'Today • ${_formatFullDate(_selectedDate!)}';
    } else {
      return _formatFullDate(_selectedDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFullDate(DateTime date) {
    return '${date.day} ${_getMonthName(date)}, ${date.year}';
  }

  void _showDeleteDialog(
    BuildContext context,
    ListsProvider provider,
    GroceryList list,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete List'),
        content: Text(
          'Are you sure you want to delete "${list.title}"? This will also delete all items in the list.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            isDefaultAction: true,
            onPressed: () {
              provider.deleteList(list.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}*/

/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/list_model.dart';
import '../providers/lists_provider.dart';
import '../widgets/add_list_bottom_sheet.dart';
import 'list_items_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<DateTime> _getDateChips() {
    final now = DateTime.now();
    final List<DateTime> dates = [];

    // Get current week days (Sunday to Saturday)
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));

    for (int i = 0; i < 7; i++) {
      dates.add(currentWeekStart.add(Duration(days: i)));
    }

    return dates;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Lists'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ListsProvider>(
        builder: (context, provider, child) {
          final filteredLists = _selectedDate == null
              ? provider.lists
              : provider.lists.where((list) {
                  return list.updatedAt.year == _selectedDate!.year &&
                      list.updatedAt.month == _selectedDate!.month &&
                      list.updatedAt.day == _selectedDate!.day;
                }).toList();

          final totalLists = filteredLists.length;
          final totalCost = filteredLists.fold<double>(0.0, (sum, list) {
            // You might want to add a method in ListsProvider to get list total cost
            return sum; // Placeholder - you'll need to implement this
          });

          return Column(
            children: [
              // Date Chips Section
              _buildDateChipsSection(),

              // Month and Year Display
              _buildMonthYearSection(),

              // Statistics Section
              _buildStatisticsSection(totalLists, totalCost),

              // Lists Section
              Expanded(child: _buildListsSection(provider, filteredLists)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddListBottomSheet.show(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateChipsSection() {
    final dateChips = _getDateChips();
    final currentMonth = dateChips.first.month;
    final currentYear = dateChips.first.year;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.green),
      child: Column(
        children: [
          // Date Chips Row
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...dateChips.map((date) {
                  final isSelected =
                      _selectedDate != null &&
                      _selectedDate!.year == date.year &&
                      _selectedDate!.month == date.month &&
                      _selectedDate!.day == date.day;

                  final isToday =
                      DateTime.now().year == date.year &&
                      DateTime.now().month == date.month &&
                      DateTime.now().day == date.day;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : isToday
                              ? Colors.blue.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : isToday
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: isToday ? 1 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getDayName(date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                      ? Colors.blue
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Custom Date Button
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'More',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearSection() {
    final selectedDate = _selectedDate ?? DateTime.now();
    final currentDay = _selectedDate?.day;
    final currentMonth = _getMonthName(selectedDate);
    final currentYear = selectedDate.year;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$currentDay $currentMonth $currentYear',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(int totalLists, double totalCost) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.green.shade100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.list_alt,
            value: totalLists.toString(),
            label: 'Total Lists',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            value: '₹${totalCost.toStringAsFixed(2)}',
            label: 'Total Cost',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildListsSection(
    ListsProvider provider,
    List<GroceryList> filteredLists,
  ) {
    if (filteredLists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _selectedDate == null
                  ? 'No grocery lists yet!'
                  : 'No lists on ${_getSelectedDateDisplay()}',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            Text(
              _selectedDate == null
                  ? 'Tap + to create your first list'
                  : 'Create a new list or select another date',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredLists.length,
      itemBuilder: (context, index) {
        final list = filteredLists[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.green),
            title: Text(
              list.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              list.description.isNotEmpty ? list.description : 'No description',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(list.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _formatTime(list.updatedAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              provider.setCurrentList(list);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListItemsScreen(),
                ),
              );
            },
            onLongPress: () {
              _showDeleteDialog(context, provider, list);
            },
          ),
        );
      },
    );
  }

  String _getSelectedDateDisplay() {
    if (_selectedDate == null) return 'All Dates';

    final now = DateTime.now();
    if (_selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day) {
      return 'Today • ${_formatFullDate(_selectedDate!)}';
    } else {
      return _formatFullDate(_selectedDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFullDate(DateTime date) {
    return '${date.day} ${_getMonthName(date)}, ${date.year}';
  }

  void _showDeleteDialog(
    BuildContext context,
    ListsProvider provider,
    GroceryList list,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete List'),
        content: Text(
          'Are you sure you want to delete "${list.title}"? This will also delete all items in the list.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            isDefaultAction: true,
            onPressed: () {
              provider.deleteList(list.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
*/
