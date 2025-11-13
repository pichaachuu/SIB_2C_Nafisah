<?php
include 'views/header.php';
?>

<h2>Masa Kerja</h2>

<?php
 // Hitung total statistics
    $stats->execute();
    $all_stats = $stats->fetchAll(PDO::FETCH_ASSOC);
?>

<table class="data-table">
    <thead>
        <tr>
            <th>Level</th>
            <th>Jumlah</th>
        </tr>
    </thead>
    <tbody>
        <?php foreach ($all_stats as $tenure): ?>
        <tr>
            <td>
                <?php echo htmlspecialchars($tenure['level']);?>
            </td>
            <td>
                <?php echo number_format($tenure['count_employees']); ?>
            </td>
        </tr>
        <?php endforeach;?>
    </tbody>
</table>