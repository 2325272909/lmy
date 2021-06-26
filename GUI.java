package Life;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class GUI extends JFrame implements ActionListener
{
    // 面板:背景面板、中部面板、底部面板
    private JPanel backPanel,centerPanel,bottomPanel;

    // 标签：行细胞数、列细胞数当前代数
    private JLabel labelRowNum,labelColNum,labelNowGeneration;

    // 文本框：行细胞数、列细胞数
    private JTextField textRowNum,textColNum;

    // 按钮：一个网格按钮表示一个细胞
    private JButton[][] btnGridCell;

    // 按钮：确定、代数清零、细胞清零、随机初始化、当前代数
    private JButton btnOK,btnClearGeneration,btnClearCell, btnRandomInit,btnNowGeneration;

    // 按钮：开始繁衍、下一代、暂停、退出
    private JButton btnAutoProduce,btnNextGeneration, btnStop, btnExit;

    // 创建Service类的变量
    private Service service;
    // 创建Logic类的对象
    Logic logic = new Logic();

    // 线程
    private Thread thread;

    // 主程序入口
    public static void main(String arg[])
    {
        new GUI();
    }

    // 构造方法
    public GUI()
    {
        // 调用父类JFrame的构造方法设置窗体标题
        super("生命游戏");

        // 初始化窗体
        initGUI();
    }

    // 初始化ui界面
    public void initGUI()
    {
        // 传递行、列细胞数值给Service类
        service = new Service(logic.getMaxRowNum(), logic.getMaxColNum());

        // 背景面板：边框布局
        backPanel = new JPanel(new BorderLayout());
        this.setContentPane(backPanel);

        // 中部面板：网格布局
        centerPanel = new JPanel(new GridLayout(logic.getMaxRowNum(), logic.getMaxColNum()));
        backPanel.add(centerPanel,"Center");

        // 底部面板：容纳各种按钮
        bottomPanel = new JPanel();
        backPanel.add(bottomPanel,"South");

        // 创建网格细胞按钮对象,按钮数组
        btnGridCell = new JButton[logic.getMaxRowNum()][logic.getMaxColNum()];

        // 初始化网格按钮数组以表示细胞
        for (int i = 0; i < logic.getMaxRowNum(); i++)
        {
            for (int j = 0; j < logic.getMaxColNum(); j++)
            {
                // 细胞网格，内容为空表示细胞
                btnGridCell[i][j] = new JButton("");
                // 细胞背景色为白色
                btnGridCell[i][j].setBackground(Color.WHITE);
                // 添加细胞网格按钮到面板
                centerPanel.add(btnGridCell[i][j]);
            }
        }

        // 标签：行细胞数
        labelRowNum = new JLabel("行细胞数:");
        bottomPanel.add(labelRowNum);

        // 文本框：行细胞数
        textRowNum = new JTextField(2);
        textRowNum.setText(""+logic.getMaxRowNum());
        bottomPanel.add(textRowNum);

        // 标签：列细胞数
        labelColNum = new JLabel("列细胞数:");
        bottomPanel.add(labelColNum);

        // 文本框：列细胞数
        textColNum = new JTextField(2);
        textColNum.setText(""+logic.getMaxColNum());
        bottomPanel.add(textColNum);

        // 按钮：确定
        btnOK = new JButton("确定");
        bottomPanel.add(btnOK);

        // 标签：当前代数
        labelNowGeneration = new JLabel("当前代数:");
        bottomPanel.add(labelNowGeneration);

        // 按钮：显示当前代数
        btnNowGeneration = new JButton(""+service.getNowGeneration());
        // 设置按钮不可点击
        btnNowGeneration.setEnabled(false);
        bottomPanel.add(btnNowGeneration);

        // 代数清零按钮
        btnClearGeneration = new JButton("代数清零");
        bottomPanel.add(btnClearGeneration);

        // 随机初始化按钮
        btnRandomInit = new JButton("随机初始化");
        bottomPanel.add(btnRandomInit);

        // 细胞清零按钮
        btnClearCell = new JButton("细胞清零");
        bottomPanel.add(btnClearCell);

        // 自动繁衍按钮
        btnAutoProduce = new JButton("自动繁衍");
        bottomPanel.add(btnAutoProduce);

        // 下一代按钮
        btnNextGeneration = new JButton("下一代");
        bottomPanel.add(btnNextGeneration);

        // 暂停按钮
        btnStop = new JButton("暂停");
        bottomPanel.add(btnStop);

        // 退出按钮
        btnExit = new JButton("退出");
        bottomPanel.add(btnExit);

        // 注册监听器
        this.addWindowListener(new WindowAdapter()
        {
            public void windowClosed(WindowEvent e)
            {
                System.exit(0);
            }
        });

        btnOK.addActionListener(this);
        btnClearGeneration.addActionListener(this);
        btnRandomInit.addActionListener(this);
        btnClearCell.addActionListener(this);
        btnNextGeneration.addActionListener(this);
        btnAutoProduce.addActionListener(this);
        btnStop.addActionListener(this);
        btnExit.addActionListener(this);
        for (int i = 0; i < logic.getMaxRowNum(); i++) {
            for (int j = 0; j < logic.getMaxColNum(); j++) {
                btnGridCell[i][j].addActionListener(this);
            }
        }

        // 设置窗体大小
        this.setSize(1000,650);
        // 窗体大小可变
        this.setResizable(true);
        // 窗体居中显示
        this.setLocationRelativeTo(null);
        // 窗体可见
        this.setVisible(true);
    }

    // 监听事件处理
    public void actionPerformed(ActionEvent e)
    {
        // 确定
        if(e.getSource() == btnOK)
        {
            // 从Logic类中获取最新的ui界面大小：行、列值
            logic.setMaxRowNum(Integer.valueOf(textRowNum.getText()));
            logic.setMaxColNum(Integer.valueOf(textColNum.getText()));

            // 传递行、列细胞数值给Service类
            service = new Service(logic.getMaxRowNum(), logic.getMaxColNum());

            // 更新窗体
            initGUI();
        }
        // 代数清零
        else if(e.getSource() == btnClearGeneration)
        {
            // 设置代数值为0
            service.setNowGeneration(0);
            // 刷新当前代数显示
            btnNowGeneration.setText(""+service.getNowGeneration());
            // 未在自动繁衍
            logic.setIsRunning(false);
        }
        // 随机初始化
        else if(e.getSource() == btnRandomInit)
        {
            // 随机初始化一部分细胞状态为1
            service.randomCell();
            // 显示细胞
            showCell();
            // 未在自动繁衍
            logic.setIsRunning(false);
        }
        // 细胞清零
        else if(e.getSource() == btnClearCell)
        {
            // 设置所有细胞状态为0
            service.deleteAllCell();
            // 显示细胞
            showCell();
            // 未在自动繁衍
            logic.setIsRunning(false);
        }
        // 自动繁衍
        else if (e.getSource() == btnAutoProduce)
        {
            // 正在自动繁衍
            logic.setIsRunning(true);
            // 自动繁衍
            autoProduce();
        }
        // 下一代
        else if (e.getSource() == btnNextGeneration)
        {
            // 产生下一代
            makeNextGeneration();
            // 未在自动繁衍
            logic.setIsRunning(false);
        }
        // 暂停
        else if (e.getSource() == btnStop)
        {
            // 未在自动繁衍
            logic.setIsRunning(false);
        }
        // 退出
        else if (e.getSource() == btnExit)
        {
            dispose();
            System.exit(0);
        }
        // 细胞按钮
        else
        {
            // 从Service类中获得每个网格细胞按钮对应的值：1或0
            int[][] grid = service.getGrid();

            for (int i = 0; i < logic.getMaxRowNum(); i++)
            {
                for (int j = 0; j < logic.getMaxColNum(); j++)
                {
                    // 点击了某一个细胞按钮
                    if (e.getSource() == btnGridCell[i][j])
                    {
                        // 修改其选择状态为相反状态
                        logic.setIsSelected(i,j);

                        // 如果选中了该细胞按钮
                        if (logic.getIsSelected(i,j))
                        {
                            // 背景色为黑色
                            btnGridCell[i][j].setBackground(Color.BLACK);
                            // 选中则设置该细胞为活细胞，状态为1
                            grid[i + 1][j + 1] = 1;
                        }
                        else
                        {
                            // 死细胞背景色为白色，状态为0
                            btnGridCell[i][j].setBackground(Color.WHITE);
                            grid[i + 1][j + 1] = 0;
                        }
                        break;
                    }
                }
            }
            // 修改Service类中与网格按钮对应多维数组中元素的值
            service.setGrid(grid);
        }
    }

    // 生成下一代
    protected void makeNextGeneration()
    {
        // 繁衍
        service.update();
        // 显示细胞
        showCell();
        // 刷新代数显示按钮
        btnNowGeneration.setText(""+service.getNowGeneration());
    }

    // 根据细胞状态显示细胞颜色
    private void showCell()
    {
        int[][] grid = service.getGrid();

        for (int i = 0; i < logic.getMaxRowNum(); i++)
        {
            for (int j = 0; j < logic.getMaxColNum(); j++)
            {
                if (grid[i + 1][j + 1] == 1)
                {
                    // 活细胞用黑色表示
                    btnGridCell[i][j].setBackground(Color.BLACK);
                }
                else
                {
                    // 死细胞用白色表示
                    btnGridCell[i][j].setBackground(Color.WHITE);
                }
            }
        }
    }

    // 自动繁衍
    private void autoProduce()
    {
        thread = new Thread(new Runnable()
        {
            public void run()
            {
                while (logic.getIsRunning())
                {
                    // 产生下一代
                    makeNextGeneration();

                    try
                    {
                        thread.sleep(500);
                    } catch (InterruptedException e1)
                    {
                        e1.printStackTrace();
                    }

                    logic.setIsDead(true);

                    for(int row = 1; row <= logic.getMaxRowNum(); row++)
                    {
                        for (int col = 1; col <= logic.getMaxColNum(); col++)
                        {
                            if (service.getGrid()[row][col] != 0)
                            {
                                logic.setIsDead(false);
                                break;
                            }
                        }
                        if (!logic.getIsDead())
                        {
                            break;
                        }
                    }

                    if (logic.getIsDead())
                    {
                        JOptionPane.showMessageDialog(null, "所有细胞已死亡");
                        logic.setIsRunning(false);
                        thread = null;
                    }
                }
            }
        });
        thread.start();
    }
}
