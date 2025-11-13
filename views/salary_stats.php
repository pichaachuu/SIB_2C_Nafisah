<?php
include 'views/header.php';
?>

<h2>Statistik Gaji</h2>

<?php
 // Hitung total statistics
 $stats->execute();
 $all_stats = $stats->fetchAll(PDO::FETCH_ASSOC);
?>

 <table class="data-table">
 <thead>
 <tr>
 <th>Departemen</th>
 <th>Gaji Rata-rata</th>
 <th>Gaji Terendah</th>
 <th>Gaji Tertinggi</th>
 </tr>
 </thead>
 <tbody>
 <?php foreach ($all_stats as $dept): ?>
 <tr>
 <td>
 <strong><?php echo htmlspecialchars($dept['department']);
?></strong>
 </td>
 <td>
 <strong>Rp <?php echo number_format($dept['avg_salary'], 0, 
',', '.'); ?></strong>
 </td>
 <td>Rp <?php echo number_format($dept['min_salary'], 0, ',', '.'); 
?></td>
 <td>Rp <?php echo number_format($dept['max_salary'], 0, ',', '.');
?></td>
 <td>

 </td>
 </tr>
 <?php endforeach;
?>
 </tbody>
 </table>

<?php 
include 'views/footer.php';
?> 