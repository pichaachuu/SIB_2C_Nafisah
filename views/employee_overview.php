<?php
include 'views/header.php';
?>

<h2>Ringkasan Karyawan</h2>


<div class="dashboard-cards">
    <div class="card">
        <h3>Total Karyawan</h3>
        <div class="number">
            <?php echo $employeeoverview['total_employees'];?>
        </div>
    </div>
    <div class="card">
        <h3>Total Gaji PerBulan</h3>
        <div class="number">
            <?php echo $employeeoverview['total_salary_per_month'];?>
        </div>
    </div>
    <div class="card">
        <h3>Rata-rata masa kerja</h3>
        <div class="number">
            <?php echo $employeeoverview['avg_years_service'];?>
        </div>
    </div>
</div>

<?php 
include 'views/footer.php';
?>